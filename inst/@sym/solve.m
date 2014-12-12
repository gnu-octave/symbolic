%% Copyright (C) 2014 Colin B. Macdonald, Andrés Prieto
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
%% @deftypefn  {Function File} {@var{sol} =} solve (@var{eqn, var})
%% Symbolic solutions of equations and systems.
%%
%% Examples
%% @example
%% solve(x==2*x+6, x)
%% solve(eq1, eq2, var1, var2)
%% solve(eq1,...,eqn, var1,...,varm)
%% @end example
%%
%% Output will be a cell array.  Each entry of the cell array is a
%% dictionary (well, a struct).  String representation of the things
%% you wanted to solve for (typically variables) are the keys of the
%% dict.
%%
%% Examples
%% @example
%% syms x y
%% e = 10*x == 20*y
%% d = solve(e, x)
%% d@{1@}.x          % gives 2*y
%% d = solve(e, y)
%% d@{1@}.y          % gives x/2
%%
%% d = solve(e, 2*x)
%% d@{1@}.('2*x')   % gives 4*y (and won't work on Matlab)
%% @end example
%%
%%
%% FIXME: when there is just one variable to be solved for, the
%% output doesn't match Matlab SMT (should not be inside a cell
%% array).  Many other forms of output to consider.
%%
%% @seealso{dsolve}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic

function out = solve(varargin)

  varargin = sym(varargin);

  % These are various special cases for the output, single versus multiple
  cmd = { 'eqs = list(); symbols = list()'
          'for arg in _ins:'
          '    if arg.is_Relational:'
          '        eqs.append(arg)'
          '    else:'
          '        symbols.append(arg)'
          '#'
          'if len(symbols) > 0:'
          '    d = sp.solve(eqs, symbols, dict=True)'
          'else:'
          '    d = sp.solve(eqs, dict=True)'
          '#'
          'if len(d) >= 1 and len(d[0].keys()) == 1:'  % one variable...
          '    if len(d) == 1:'  % one variable, single solution
          '        return d[0].popitem()[1],'
          '    else:'  % one variable, multiple solutions
          '        return sp.Matrix([r.popitem()[1] for r in d]),'
          '#'
          'if len(d) == 1:'
          '    d = d[0]'
          'return d,' };

  out = python_cmd (cmd, varargin{:});

end



%!test
%! % Simple, single variable, single solution
%! syms x
%! d = solve(10*x == 50);
%! assert (isequal (d, 5))

%!test
%! % Single variable, multiple solutions
%! syms x
%! d = solve(x^2 == 4);
%! assert (length(d) == 2);
%! assert (isequal (d, [2; -2]) || isequal (d, [-2; 2]))

%!shared x,y,e
%! syms x y
%! e = 10*x == 20*y;
%!test
%! d = solve(e, x);
%! assert (isequal (d, 2*y))
%!test
%! d = solve(e, y);
%! assert (isequal (d, x/2))
%!test
%! d = solve(e);
%! assert (isequal (d, 2*y))

%!test
%! % solve for 2*x (won't work on Matlab/Octave 3.6)
%! if 1==0 && exist('octave_config_info', 'builtin')
%!   if (compare_versions (OCTAVE_VERSION (), '3.8.0', '>='))
%!     d = solve(e, 2*x);
%!     s = d.('2*x');
%!     assert (isequal (s, 4*y))
%!   end
%! end

%!test
%! d = solve(2*x - 3*y == 0, x + y == 1);
%! assert (isequal (d.x, sym(3)/5) && isequal(d.y, sym(2)/5))

%!test
%! d = solve(2*x-3*y==0,x+y==1,x,y);
%! assert (isequal (d.x, sym(3)/5) && isequal(d.y, sym(2)/5))

%!test
%! % Multiple solutions, multiple variables
%! d = solve(x^2 == 4, x + y == 1);
%! assert (length(d) == 2);
%! % FIXME: SMT has d.x gives vector and d.y giving vector, what is
%! % more intuitive?
%! for i = 1:2
%!   assert (isequal (d{i}.x + d{i}.y, 1))
%!   assert (isequal ((d{i}.x)^2, 4))
%! end

%!test
%! % No solutions
%! syms x y z
%! d = solve(x == y, z);
%! assert (isempty (d));
