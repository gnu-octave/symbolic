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
%% Keywords: symbolic, symbols

function L = findsymbols(x)

  cmd = [ 'def fcn(_ins):\n'                                          ...
          '    #sys.stderr.write("pydebug: " + str(_ins) + "\\n")\n'   ...
          '    s = _ins[0].free_symbols\n'                                  ...
          '    l = list(s)\n'                                  ...
          '    l.sort()\n'                                  ...
          '    #sys.stderr.write("pydebug: " + str(l) + "\\n")\n'      ...
          '    return (l)\n' ];

  L = python_sympy_cmd_retcell (cmd, x);


%!test
%! syms x b y n a arlo
%! z = a*x + b*pi*sin (n) + exp (y) + exp (sym (1)) + arlo;
%! s = findsymbols (z);
%! assert (isequal ([s{:}], [a,arlo,b,n,x,y]))
%!test syms x
%! s = findsymbols (x);
%! assert (isequal (s{1}, x))
%!assert (isempty (findsymbols (sym (nan))))
%!assert (isempty (findsymbols (sym (inf))))
%!assert (isempty (findsymbols (exp (sym (2)))))

