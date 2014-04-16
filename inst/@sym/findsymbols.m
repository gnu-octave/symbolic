%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -- Loadable Function: L = findsymbols (X)
%%     Return a list (cell array) of the symbols in a symbolic expression
%%
%%     The list is sorted alphabetically..
%%
%%     Note E, I, pi, etc are not counted as symbols.

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, find

function L = findsymbols(x)


  % l.sort() fails on sympy 0.7.5
  cmd = [ 'def fcn(_ins):\n'                            ...
          '    x = _ins[0]\n'                           ...
          '    if not x.is_Matrix:\n'                   ...
          '        s = x.free_symbols\n'                ...
          '    else:\n'                                 ...
          '        s = set()\n'                         ...
          '        for i in x.values():\n'              ...
          '            s = s.union(i.free_symbols)\n'   ...
          '    l = list(s)\n'                           ...
          '    #dbout("warning: will fail on sympy 0.7.5")\n' ...
          '    #dbout(("we are", sp.__version__))\n' ...
          '    # FIXME: workaround for SymPy bug: #7413\n' ...
          '    l = sorted(l, key=str)\n'                ...
          '    return (l,)\n' ];

  L = python_sympy_cmd (cmd, x);


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

