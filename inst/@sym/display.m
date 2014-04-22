%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn {Function File}  {} display (@var{x})
%% Display, on command line, the contents of a symbolic expression
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function display(obj)

  % Note: if you edit this, make sure you edit disp.m as well

  %% Settings
  unicode_decorations = true;
  display_snippet = octsympy_config('snippet');
  loose = strcmp(get(0,'FormatSpacing'), 'loose');

  if (unicode_decorations)
    timesstr = '×';
  else
    timesstr = '×';
  end

  d = size (obj);
  if (isscalar (obj))
    fprintf ('%s = (%s)', inputname (1), class (obj))
    fprintf (' %s', obj.flattext)

    if (display_snippet)
      fprintf ('     ')
      snippet_of_sympy (obj, unicode_decorations)
    else
      fprintf ('\n')
    end

  elseif (isempty (obj))
    % Examples of 2x0 and 0x2 empty matrices:
    % a = sym([1 2; 3 4])
    % a([true true], [false false])
    % a([false false],[true true])
    formatstr = [ '%s = (%s) %s (empty %d' timesstr '%d matrix)' ];
    fprintf (formatstr, inputname (1), class (obj), obj.text, d(1), d(2))

    if (display_snippet)
      fprintf ('     ')
      snippet_of_sympy (obj, unicode_decorations)
    else
      fprintf ('\n')
    end

  elseif (length (d) == 2)
    %% 2D Array
    formatstr = [ '%s = (%s %d' timesstr '%d matrix)' ];
    fprintf (formatstr, inputname (1), class (obj), d(1), d(2))

    if (display_snippet)
      fprintf ('        ')
      snippet_of_sympy (obj, unicode_decorations)
    else
      fprintf ('\n')
    end

    if (loose), fprintf ('\n'); end

    print_indented (obj.text)

    if (loose), fprintf ('\n'); end

  else
    %% nD Array
    % (not possible with sympy matrix)
    fprintf ('%s = (%s nD array) ...\n', inputname (1), class (obj))
    fprintf ('%s', obj.text)
  end
end

function print_indented(s, n)
  if (nargin == 1)
    n = 3;
  end
  pad = char (double (' ')*ones (1,n));
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
  disp(s)
end


function snippet_of_sympy(obj, unicode_decorations)

  if (unicode_decorations)
    ell = '…';
    lquot = '“'; rquot = '”';
  else
    ell = '...';
    lquot = '"'; rquot = lq;
  end
  % trim newlines (if there are any)
  %s = regexprep (obj.pickle, '\n', '\\n');
  s = regexprep (obj.pickle, '\n', '\');
  len = length (s);
  if len > 42
    s = [s(1:42) ell];
  end
  fprintf ([lquot '%s' rquot '\n'], s);
end
