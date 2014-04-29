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
%% @deftypefn  {Function File} {@var{l} =} findsymbols (@var{x})
%% Return a list (cell array) of the symbols in a symbolic expression.
%%
%% The list is sorted alphabetically.
%%
%% Note E, I, pi, etc are not counted as symbols.

%% Similar behaviour to the built-in @code{all} with regard to
%% matrices and the second argument.
%%
%% Throws an error if any entries are non-numeric.
%%
%% @seealso{symvar, findsym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function L = findsymbols(x)

  cmd = [ 'x = _ins[0]\n'                       ...
          'if not x.is_Matrix:\n'               ...
          '    s = x.free_symbols\n'            ...
          'else:\n'                             ...
          '    s = set()\n'                     ...
          '    for i in x.values():\n'          ...
          '        s = s.union(i.free_symbols)\n' ...
          'l = list(s)\n'                       ...
          'l = sorted(l, key=str)\n'            ...
          'return (l,)' ];

  L = python_cmd (cmd, x);

end


%!test
%! syms x b y n a arlo
%! z = a*x + b*pi*sin (n) + exp (y) + exp (sym (1)) + arlo;
%! s = findsymbols (z);
%! assert (isequal ([s{:}], [a,arlo,b,n,x,y]))
%!test
%! syms x
%! s = findsymbols (x);
%! assert (isequal (s{1}, x))
%!test
%! syms z x y a
%! s = findsymbols ([x y; 1 a]);
%! assert (isequal ([s{:}], [a x y]))
%!assert (isempty (findsymbols (sym (1))))
%!assert (isempty (findsymbols (sym ([1 2]))))
%!assert (isempty (findsymbols (sym (nan))))
%!assert (isempty (findsymbols (sym (inf))))
%!assert (isempty (findsymbols (exp (sym (2)))))

