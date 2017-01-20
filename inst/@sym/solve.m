%% Copyright (C) 2014-2016 Colin B. Macdonald
%% Copyright (C) 2014-2015 Andrés Prieto
%% Copyright (C) 2016 Lagu
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
%% @deftypemethod  @@sym {@var{sol} =} solve (@var{eq, var})
%% @deftypemethodx @@sym {@var{sol} =} solve (@var{eq1, eq2})
%% @deftypemethodx @@sym {@var{sol} =} solve (@var{eq1, @dots{}, eqn, v1, @dots{}, vm})
%% @deftypemethodx @@sym {[@var{s1, @dots{}, sn}] =} solve (@var{eq1, @dots{}, eqm, v1, @dots{}, vn})
%% Symbolic solutions of equations, inequalities and systems.
%%
%% Examples
%% @example
%% @group
%% syms x
%% solve (x == 2*x + 6, x)
%%   @result{} ans = (sym) -6
%% solve (x^2 + 6 == 5*x, x)
%%   @result{} ans = (sym 2×1 matrix)
%%       ⎡2⎤
%%       ⎢ ⎥
%%       ⎣3⎦
%% @end group
%% @end example
%%
%% In general, the output will be a list of dictionaries.  Each
%% entry of the list is one a solution, and the variables that make
%% up that solutions are keys of the dictionary (fieldnames of the
%% struct).
%% @example
%% @group
%% syms x y
%% d = solve(x^2 == 4, x + y == 1);
%%
%% % the first solution
%% d@{1@}.x
%%   @result{} (sym) -2
%% d@{1@}.y
%%   @result{} (sym) 3
%%
%% % the second solution
%% d@{2@}.x
%%   @result{} (sym) 2
%% d@{2@}.y
%%   @result{} (sym) -1
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
%% [X, Y] = solve (x^2 == 4, x + y == 1, x, y)
%%   @result{} X = (sym 2×1 matrix)
%%       ⎡-2⎤
%%       ⎢  ⎥
%%       ⎣2 ⎦
%%   @result{} Y = (sym 2×1 matrix)
%%       ⎡3 ⎤
%%       ⎢  ⎥
%%       ⎣-1⎦
%% @end group
%% @end example
%%
%% You can solve inequalities and systems involving mixed
%% inequalities and equations.  For example:
%% @example
%% @group
%% solve (x^2 == 4, x > 0)
%%   @result{} ans = (sym) x = 2
%% @end group
%% @group
%% solve (x^2 - 1 > 0, x < 10)
%%   @result{} ans = (sym) (-∞ < x ∧ x < -1) ∨ (1 < x ∧ x < 10)
%% @end group
%% @end example
%%
%% @seealso{@@sym/eq, @@sym/dsolve}
%% @end deftypemethod


function varargout = solve(varargin)

  varargin = sym (varargin);

  %% base use {extra} section to add specific options to solve
  %% if you don't need it replace it with an empty string
  base = { 'eqs = list(); symbols = list()'
           'for arg in _ins:'
           '    if arg.is_Relational:'
           '        eqs.append(arg)'
           '    else:'
           '        symbols.append(arg)'
           'd = sp.solve(eqs, *symbols{extra})'
           'if not isinstance(d, (list, tuple)):'  % https://github.com/sympy/sympy/issues/11661
           '    return d,' };

  if (nargout == 0 || nargout == 1)
    cmd = { 'if len(d) >= 1 and len(d[0].keys()) == 1:'  % one variable...
            '    if len(d) == 1:'  % one variable, single solution
            '        return d[0].popitem()[1],'
            '    else:'  % one variable, multiple solutions
            '        return sp.Matrix([r.popitem()[1] for r in d]),'
            'if len(d) == 1:'
            '    d = d[0]'
            'return d,' };

    out = python_cmd ([strrep(base, '{extra}', ', dict=True'); cmd], varargin{:});

    varargout = {out};

  else  % multiple outputs
    cmd = { '(vars, solns) = d'
            'q = []'
            'for (i, var) in enumerate(vars):'
            '    q.append(sp.Matrix([t[i] for t in solns]))'
            'return q,' };

    out = python_cmd ([strrep(base, '{extra}', ', set=True'); cmd], varargin{:});

    assert (isequal (nargout, length (out)), ['This system have ' num2str(length (out)) ' vars solution, please set correct numbers of outputs.']);

    varargout = out;

  end

end


%!test
%! % Simple, single variable, single solution
%! syms x
%! d = solve (10*x == 50);
%! assert (isequal (d, 5))

%!test
%! % Single variable, multiple solutions
%! syms x
%! d = solve (x^2 == 4);
%! assert (length (d) == 2);
%! assert (isequal (d, [2; -2]) || isequal (d, [-2; 2]))

%!shared x,y,e
%! syms x y
%! e = 10*x == 20*y;
%!test
%! d = solve (e, x);
%! assert (isequal (d, 2*y))
%!test
%! d = solve (e, y);
%! assert (isequal (d, x/2))
%!test
%! d = solve (e);
%! assert (isequal (d, 2*y))

%!test
%! % Solve for an expression 2*x instead of a variable.  Note only very
%! % simple examples will work, see "?solve" in SymPy, hence this is no
%! % longer documented in the help text.
%! d = solve (e, 2*x);
%! assert (isequal (d, 4*y))

%!test
%! d = solve (2*x - 3*y == 0, x + y == 1);
%! assert (isequal (d.x, sym (3)/5) && isequal (d.y, sym (2)/5))

%!test
%! d = solve(2*x - 3*y == 0,x + y == 1,x,y);
%! assert (isequal (d.x, sym (3)/5) && isequal (d.y, sym (2)/5))

%!test
%! % Multiple solutions, multiple variables
%! d = solve (x^2 == 4, x + y == 1);
%! assert (length (d) == 2);
%! % FIXME: SMT has d.x gives vector and d.y giving vector, what is
%! % more intuitive?
%! for i = 1:2
%!   assert (isequal (d{i}.x + d{i}.y, 1))
%!   assert (isequal ((d{i}.x)^2, 4))
%! end

%!test
%! % No solutions
%! syms x y z
%! d = solve (x == y, z);
%! assert (isempty (d));

%!test
%! % Multiple outputs with single solution
%! syms x y
%! [X, Y] = solve (2*x + y == 5, x + y == 3);
%! assert (isequal (X, 2))
%! assert (isequal (Y, 1))

%!test
%! % Multiple outputs with multiple solns
%! syms x y
%! [X, Y] = solve (x*x == 4, x == 2*y);
%! assert (isequal (X, [2; -2]))
%! assert (isequal (Y, [1; -1]))

%!test
%! % Multiple outputs with multiple solns, specify vars
%! syms x y
%! [X, Y] = solve (x*x == 4, x == 2*y, x, y);
%! assert (isequal (X, [2; -2]))
%! assert (isequal (Y, [1; -1]))

%!test
%! syms x
%! a = solve (2*x >= 10, 10*x <= 50);
%! assert (isequal (a, x == sym (5)))

%!error
%! syms x
%! [a b] = solve (x^2 + x == 0)

%!error
%! syms a b
%! solve (a == b, 1 == 1)

%!error
%! syms a b
%! solve (a == b, 1 == 2)
