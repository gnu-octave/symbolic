%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn {Function File}  {} display (@var{x})
%% Display, on command line, the contents of a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% >> x = sym('x')
%%  @result{} x = (sym) x
%%
%% >> display(x)
%%  @result{} x = (sym) x
%%
%% >> display([x 2 pi])
%%  @result{} = (sym 1×3 matrix)
%%
%%  [x  2  π]
%% @end group
%% @end example
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function display(x)

  %% Settings
  wh = sympref('display');
  if (strcmp(wh, 'unicode'))
    unicode_dec = true;
  else
    unicode_dec = false;
  end
  display_snippet = sympref('snippet');
  loose = strcmp(get(0,'FormatSpacing'), 'loose');

  %% Get terminal width, mainly for snippets
  % works in matlab gui & -nodesktop but not the most up-to-date
  % approach
  [term_width] = get(0, 'CommandWindowSize');
  if (isequal(term_width, [0 0]))
    % octave gives [0 0], at least as of August 2014.
    [term_width] = terminal_size();
    % octave has [height width]
    term_width = term_width(2);
  else
    % matlab has [width height]
    term_width = term_width(1);
  end

  if (unicode_dec)
    timesstr = '×';
  else
    timesstr = 'x';
  end
  newl = sprintf('\n');

  % an appropriate label for this variable, likely just inputname itself
  name = priv_disp_name(x, inputname (1));
  d = size (x);

  % sort of isinstance(x, MatrixExpr) but cheaper
  is_matrix_symbol = false;
  matexprlist = {'MatrixSymbol' 'MatMul' 'MatAdd' 'MatMul'};
  for i=1:length(matexprlist)
    if (strncmp(char(x), matexprlist{i}, length(matexprlist{i})))
      is_matrix_symbol = true;
    end
  end

  if (isscalar (x)) && (~is_matrix_symbol)
    n = fprintf ('%s = (%s)', name, class (x));
    s = strtrim(disp(x));
    hasnewlines = strfind(s, newl);
    % FIXME: length(s) lies on Octave; it counts bytes not chars
    toobig = ~isempty(hasnewlines) || (length(s) + n + 18 > term_width);
    if (~toobig)
      fprintf(' %s', s)
      n = n + 1 + length(s);
      snippet_of_sympy (x, 7, term_width - n, unicode_dec)
    else
      snippet_of_sympy (x, 7, term_width - n, unicode_dec)
      if (loose), fprintf ('\n'); end
      disp(x)
      if (loose), fprintf ('\n'); end
    end

  elseif (is_matrix_symbol)
    %if (any(isnan(d)))  % may not tell the truth
    if (any(isnan(x.size)))
      [nn, mm] = python_cmd('return (_ins[0].rows, _ins[0].cols)', x);
      numrstr = strtrim(disp(nn, 'flat'));
      numcstr = strtrim(disp(mm, 'flat'));
    else
      numrstr = num2str(d(1));
      numcstr = num2str(d(2));
    end
    if (logical(nn == 0) || logical(mm == 0))
      estr = 'empty ';
    else
      estr = '';
    end
    numrstr = strtrim(disp(nn, 'flat'));
    numcstr = strtrim(disp(mm, 'flat'));
    n = fprintf ('%s = (%s) %s (%s%s%s%s matrix expression)', name, ...
                 class (x), strtrim(disp(x)), estr, numrstr, timesstr, numcstr);
    if (unicode_dec)
      n = n - 1;  % FIXME: b/c times unicode is two bytes
    end
    snippet_of_sympy (x, 7, term_width - n, unicode_dec)



  elseif (isempty (x))
    n = fprintf ('%s = (%s) %s (empty %g%s%g matrix)', name, ...
                 class (x), strtrim(disp(x)), d(1), timesstr, d(2));
    if (unicode_dec)
      n = n - 1;  % FIXME: b/c times unicode is two bytes
    end
    snippet_of_sympy (x, 7, term_width - n, unicode_dec)


  elseif (length (d) == 2)
    %% 2D Array
    n = fprintf ('%s = (%s %g%s%g matrix)', name, class (x), ...
                 d(1), timesstr, d(2));
    if (unicode_dec)
      n = n - 1;  % FIXME: b/c times unicode is two bytes
    end
    snippet_of_sympy (x, 7, term_width - n, unicode_dec)

    if (loose), fprintf ('\n'); end
    disp(x)
    if (loose), fprintf ('\n'); end


  else
    %% nD Array
    % (not possible with sympy matrix)
    fprintf ('%s = (%s nD array)', name, class (x))

    snippet_of_sympy (x, 7, term_width - n, unicode_dec)

    if (loose), fprintf ('\n'); end
    disp(x)
    if (loose), fprintf ('\n'); end
  end
end


function snippet_of_sympy(x, padw, width, unicode)

  if ( ~ sympref('snippet'))
    fprintf('\n');
    return
  end

  if (unicode)
    ell = '…';
    lquot = '“'; rquot = '”';
    lendec = 3;
  else
    ell = '...';
    lquot = '"'; rquot = lquot;
    lendec = 5;
  end

  rightpad = 1;

  % indent
  pad = repmat(' ', 1, padw);

  % trim newlines (if there are any)
  s = regexprep (x.pickle, '\n', '\\n');
  % no unicode in pickle (I think) so this length is (probably) reliable
  len = length (s);
  if (len > (width - padw - rightpad - 2))
    n = width - rightpad - padw - lendec;
    s = [s(1:n) ell];
  end
  fprintf([pad lquot '%s' rquot '\n'], s)
end


% FIXME: Could quietly test with "evalc", but [missing in
% Octave](https://savannah.gnu.org/patch/?8033).  For now, a dummy test.
%!test
%! assert(true)
