%% Copyright (C) 2014, 2015 Colin B. Macdonald, Andrés Prieto
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
%% @deftypefn  {Function File} {@var{sol} =} solve (@var{eq, var})
%% @deftypefnx {Function File} {@var{sol} =} solve (@var{eq1, eq2})
%% @deftypefnx {Function File} {@var{sol} =} solve (@var{eq1, @dots{}, eqn, v1, @dots{}, vm})
%% @deftypefnx {Function File} {[@var{s1, @dots{}, sn}] =} solve (@var{eq1, @dots{}, eqm, v1, @dots{}, vn})
%% Symbolic solutions of equations and systems.
%%
%% Examples
%% @example
%% @group
%% >> syms x
%% >> solve(x == 2*x + 6, x)
%%    @result{} ans = (sym) -6
%% >> solve(x^2 + 6 == 5*x, x)
%%    @result{} ans = (sym 2×1 matrix)
%%        ⎡2⎤
%%        ⎢ ⎥
%%        ⎣3⎦
%% @end group
%% @end example
%%
%% You can specify a variable or even an expression to solve for:
%% @example
%% @group
%% >> syms x y
%% >> e = 10*x == 20*y;
%% >> d = solve(e, x)    % gives 2*y
%%    @result{} d = (sym) 2⋅y
%% >> d = solve(e, y)    % gives x/2
%%    @result{} d = (sym)
%%        x
%%        ─
%%        2
%% >> d = solve(e, 2*x)  % gives 4*y
%%    @result{} d = (sym) 4⋅y
%% @end group
%% @end example
%%
%% In general, the output will be a list of dictionaries.  Each
%% entry of the list is one a solution, and the variables that make
%% up that solutions are keys of the dictionary (fieldnames of the
%% struct).
%% @example
%% @group
%% >> syms x y
%% >> d = solve(x^2 == 4, x + y == 1);
%%
%% >> % the first solution
%% >> d@{1@}.x
%%    @result{} (sym) -2
%% >> d@{1@}.y
%%    @result{} (sym) 3
%%
%% >> % the second solution
%% >> d@{2@}.x
%%    @result{} (sym) 2
%% >> d@{2@}.y
%%    @result{} (sym) -1
%% @end group
%% @end example
%%
%% But there are various special cases for the output (single
%% versus multiple variables, single versus multiple solutions,
%% etc).
%% FIXME: provide a 'raw_output' argument or something to
%% always give the general output.
%%
%% Alternatively:
%% @example
%% @group
%% >> [X, Y] = solve(x^2 == 4, x + y == 1, x, y)
%%    @result{} X = (sym 2×1 matrix)
%%        ⎡-2⎤
%%        ⎢  ⎥
%%        ⎣2 ⎦
%%      Y = (sym 2×1 matrix)
%%        ⎡3 ⎤
%%        ⎢  ⎥
%%        ⎣-1⎦
%% @end group
%% @end example
%%
%% @seealso{dsolve}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic

function varargout = solve(varargin)

  varargin = sym(varargin);

  if (nargout == 0 || nargout == 1)
    cmd = { 'eqs = list(); symbols = list()'
            'for arg in _ins:'
            ' if arg.is_Relational:'
            '  eqs.append(arg)'
            ' else:'
            '  symbols.append(arg)'
            '#'
            'try:'
            ' if len(symbols) > 0:'
            '  d = sp.solve(eqs, symbols, dict=True)'
            ' else:'
            '  d = sp.solve(eqs, dict=True)'
            'except Exception as e:'
            ' return (1, type(e).__name__ + ": " + str(e))'
            '#'
            'if len(d) >= 1 and len(d[0].keys()) == 1:'  % one variable...
            ' if len(d) == 1:'  % one variable, single solution
            '  return (0, d[0].popitem()[1])'
            ' else:'  % one variable, multiple solutions
            '  return (0, sp.Matrix([r.popitem()[1] for r in d]))'
            '#'
            'if len(d) == 1:'
            ' d = d[0]'
            'return (0, d)' };

    [flag, out] = python_cmd (cmd, varargin{:});

    if (flag)
      error(out)
    end

    varargout = {out};

  else  % multiple outputs
    cmd = { 'eqs = list(); symbols = list()'
            'for arg in _ins:'
            ' if arg.is_Relational:'
            '  eqs.append(arg)'
            ' else:'
            '  symbols.append(arg)'
            '#'
            'try:'
            ' if len(symbols) > 0:'
            '  (vars, solns) = sp.solve(eqs, symbols, set=True)'
            ' else:'
            '  (vars, solns) = sp.solve(eqs, set=True)'
            'except Exception as e:'
            ' return (1, type(e).__name__ + ": " + str(e))'
            '#'
            'd = []'
            'for (i, var) in enumerate(vars):'
            ' d.append(sp.Matrix([t[i] for t in solns]))'
            'return (0, d)' };

    [flag, out] = python_cmd (cmd, varargin{:});

    if (flag)
      error(out)
    end

    varargout = out;
    
    if (length(out) ~= nargout)
      warning('solve: number of outputs did not match solution vars');
    end

  end

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
%! % now this works because we don't return a dict, see next comments
%! d = solve(e, 2*x);
%! assert (isequal (d, 4*y))

%%!test
%%! % solve for 2*x (won't work on Matlab/Octave 3.6)
%%! % FIXME: design a test with both x and y?  Should we support this?
%%! if exist('octave_config_info', 'builtin')
%%!   if (compare_versions (OCTAVE_VERSION (), '3.8.0', '>='))
%%!     d = solve(e, 2*x);
%%!     s = d.('2*x');
%%!     assert (isequal (s, 4*y))
%%!   end
%%! end

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

%!test
%! % Multiple outputs with single solution
%! syms x y
%! [X, Y] = solve(2*x + y == 5, x + y == 3);
%! assert (isequal (X, 2))
%! assert (isequal (Y, 1))

%!test
%! % Multiple outputs with multiple solns
%! syms x y
%! [X, Y] = solve(x*x == 4, x == 2*y);
%! assert (isequal (X, [2; -2]))
%! assert (isequal (Y, [1; -1]))

%!test
%! % Multiple outputs with multiple solns, specify vars
%! syms x y
%! [X, Y] = solve(x*x == 4, x == 2*y, x, y);
%! assert (isequal (X, [2; -2]))
%! assert (isequal (Y, [1; -1]))

%!error
%! syms a b;
%! solve(a==b, 1==1)

%!error
%! syms a b;
%! solve(a==b, 1==2)
