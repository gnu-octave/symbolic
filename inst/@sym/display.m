%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod @@sym display (@var{x})
%% Display, on command line, the contents of a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% x = sym('x')
%%   @result{} x = (sym) x
%%
%% display(x)
%%   @result{} x = (sym) x
%%
%% display([x 2 pi])
%%   @result{} (sym) [x  2  π]  (1×3 matrix)
%% @end group
%% @end example
%%
%% Other examples:
%% @example
%% @group
%% A = sym([1 2; 3 4])
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%% @end group
%%
%% @group
%% syms n
%% A = sym('A', [n n])
%%   @result{} A = (sym) A  (n×n matrix expression)
%% B = 3*A
%%   @result{} B = (sym) 3⋅A  (n×n matrix expression)
%%
%% A = sym(ones(0, 3))
%%   @result{} A = (sym) []  (empty 0×3 matrix)
%%
%% A = sym('A', [0, n])
%%   @result{} A = (sym) A  (empty 0×n matrix expression)
%% B = 3*A
%%   @result{} B = (sym) 3⋅A  (empty 0×n matrix expression)
%% @end group
%% @end example
%%
%% @seealso{@@sym/disp}
%% @end defmethod


function display(x)

  %% Settings
  wh = sympref('display');
  if (strcmp(wh, 'unicode'))
    unicode_dec = true;
  else
    unicode_dec = false;
  end
  if (exist('OCTAVE_VERSION', 'builtin') && ...
      compare_versions (OCTAVE_VERSION (), '4.3.0', '>='))
    [fmt, spacing] = format();
    loose = strcmp (spacing, 'loose');
  elseif (exist('OCTAVE_VERSION', 'builtin') && ...
      compare_versions (OCTAVE_VERSION (), '4.0.0', '>='))
    % Octave 4.1 dropped (temporarily?) the get(0,...) approach
    loose = eval('! __compactformat__ ()');
  else
    % Matlab and Octave < 4
    loose = strcmp(get(0, 'FormatSpacing'), 'loose');
  end

  % weird hack to support "ans(x) = " output for @symfun
  name = private_disp_name(x, inputname (1));

  dispstr = disp (x);
  dispstrtrim = strtrim (dispstr);
  hasnewlines = ~isempty (strfind (dispstrtrim, sprintf('\n')));

  [desc_start, desc_end] = sym_describe (x, unicode_dec);

  toobig = hasnewlines;
  %toobig = hasnewlines || ~(isempty(x) || isscalar(x));

  s1 = '';
  if (~isempty(name))
    s1 = sprintf ('%s = ', name);
  end

  if (toobig)
    if (isempty(desc_end))
      s2 = sprintf('(%s)', desc_start);
    else
      s2 = sprintf('(%s %s)', desc_start, desc_end);
    end
  else
    if (isempty(desc_end))
      s2 = sprintf('(%s) %s', desc_start, dispstrtrim);
    else
      s2 = sprintf('(%s) %s  (%s)', desc_start, dispstrtrim, desc_end);
    end
  end
  s = [s1 s2];
  disp (s)

  if (toobig)
    if (loose), fprintf ('\n'); end
    % don't use printf b/c ascii-art might have slashes
    disp (dispstr(1:end-1));  % remove existing newline, disp adds one
    if (loose), fprintf ('\n'); end
  end
end


function [s1 s2] = sym_describe(x, unicode_dec)
  if (unicode_dec)
    %timesstr = '×';  % https://savannah.gnu.org/bugs/index.php?56072
    timesstr = do_highbyte_escapes('\xc3\x97');
  else
    timesstr = 'x';
  end

  s1 = class (x);
  srepr = sympy (x);
  d = size (x);

  % sort of isinstance(x, MatrixExpr) but cheaper
  is_matrix_symbol = false;
  matexprlist = {'MatrixSymbol' 'MatMul' 'MatAdd' 'MatPow'};
  for i=1:length(matexprlist)
    if (strncmp(srepr, matexprlist{i}, length(matexprlist{i})))
      is_matrix_symbol = true;
    end
  end

  if (isscalar (x)) && (~is_matrix_symbol)
    s2 = '';
  elseif (is_matrix_symbol)
    %if (any(isnan(d)))  % may not tell the truth
    if (any(isnan(x.size)))
      [nn, mm] = pycall_sympy__ ('return (_ins[0].rows, _ins[0].cols)', x);
      numrstr = strtrim(disp(nn, 'flat'));
      numcstr = strtrim(disp(mm, 'flat'));
    else
      nn = d(1);  mm = d(2);
      numrstr = num2str(d(1), '%g');
      numcstr = num2str(d(2), '%g');
    end
    if (logical(nn == 0) || logical(mm == 0))
      estr = 'empty ';
    else
      estr = '';
    end
    s2 = sprintf ('%s%s%s%s matrix expression', estr, numrstr, timesstr, numcstr);
  elseif (length (d) == 2)
    if (isempty (x))
      estr = 'empty ';
    else
      estr = '';
    end
    s2 = sprintf ('%s%g%s%g matrix', estr, d(1), timesstr, d(2));
  else
    s2 = sprintf ('%d-dim array', length (d))
  end
end


% FIXME: Could quietly test with "evalc", but [missing in
% Octave](https://savannah.gnu.org/patch/?8033).  For now, a dummy
% test.  Doctests will cover this anyway.
%!test
%! assert(true)
