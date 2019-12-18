%% Copyright (C) 2014-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{sol} =} solve (@var{eqn})
%% @deftypemethodx @@sym {@var{sol} =} solve (@var{eqn}, @var{var})
%% @deftypemethodx @@sym {@var{sol} =} solve (@var{eqn1}, @dots{}, @var{eqnN})
%% @deftypemethodx @@sym {@var{sol} =} solve (@var{eqn1}, @dots{}, @var{eqnN}, @var{var1}, @dots{}, @var{varM})
%% @deftypemethodx @@sym {@var{sol} =} solve (@var{eqns}, @var{vars})
%% @deftypemethodx @@sym {[@var{s1, @dots{}, sn}] =} solve (@var{eqns}, @var{vars})
%% Symbolic solutions of equations, inequalities and systems.
%%
%% Examples
%% @example
%% @group
%% syms x
%% solve(x == 2*x + 6, x)
%%   @result{} ans = (sym) -6
%% solve(x^2 + 6 == 5*x, x);
%% sort(ans)
%%   @result{} ans = (sym 2×1 matrix)
%%       ⎡2⎤
%%       ⎢ ⎥
%%       ⎣3⎦
%% @end group
%% @end example
%%
%% Sometimes its helpful to assume an unknown is real:
%% @example
%% @group
%% syms x real
%% solve(abs(x) == 1, x);
%% sort(ans)
%%   @result{} ans = (sym 2×1 matrix)
%%       ⎡-1⎤
%%       ⎢  ⎥
%%       ⎣1 ⎦
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
%% @c doctest: +SKIP  % nondeterministic ordering
%% d@{1@}.x
%%   @result{} (sym) -2
%% @c doctest: +SKIP  % nondeterministic ordering
%% d@{1@}.y
%%   @result{} (sym) 3
%%
%% % the second solution
%% @c doctest: +SKIP  % nondeterministic ordering
%% d@{2@}.x
%%   @result{} (sym) 2
%% @c doctest: +SKIP  % nondeterministic ordering
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
%% @c doctest: +SKIP  % nondeterministic ordering
%% [X, Y] = solve(x^2 == 4, x + y == 1, x, y)
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
%% solve(x^2 == 4, x > 0)
%%   @result{} ans = (sym) x = 2
%% @end group
%%
%% @group
%% syms x
%% solve(x^2 - 1 > 0, x < 10)
%%   @result{} ans = (sym) (-∞ < x ∧ x < -1) ∨ (1 < x ∧ x < 10)
%% @end group
%% @end example
%%
%% @seealso{@@sym/eq, @@sym/dsolve}
%% @end deftypemethod


function varargout = solve(varargin)

  for i = 1:nargin
    varargin{i} = sym(varargin{i});
  end

  %% input parsing explanation
  % stage 0: no equations found yet
  % stage 1: equations found, could be more
  % stage 2: started finding symbols
  % stage 3: done, no more input expected
  cmd = { 'eqs = list(); symbols = list()'
          'stage = 0'
          'for arg in _ins:'
          '    if arg.is_Matrix:'
          '        if any([a.is_Relational for a in arg]):'
          '             assert stage == 0 or stage == 1'
          '             eqs.extend(arg)'
          '             stage = 1'
          '        elif stage == 0:'
          '             eqs.extend(arg)'
          '             stage = 1'
          '        else:'
          '             assert stage != 0 or stage == 1 or stage == 2'
          '             symbols.extend(arg)'
          '             stage = 3'
          '    elif arg.is_Symbol and stage == 0:'
          '        eqs.append(arg)'
          '        stage = 1'
          '    elif arg.is_Symbol:'
          '        assert stage != 0 or stage == 1 or stage == 2'
          '        symbols.append(arg)'
          '        stage = 2'
          '    else:'
          '        # e.g., Relational, or Expr implicitly assumed == 0'
          '        assert stage == 0 or stage == 1'
          '        eqs.append(arg)'
          '        stage = 1'
          'eqs = [e for e in eqs if e not in (True, S.true)]'  % https://github.com/sympy/sympy/issues/14632
        };

  if (nargout == 0 || nargout == 1)
    cmd = [ cmd
            'd = sp.solve(eqs, *symbols, dict=True)'
            'if not isinstance(d, (list, tuple)):'  % https://github.com/sympy/sympy/issues/11661
            '    return d,'
            'if len(d) >= 1 and len(d[0].keys()) == 1:'  % one variable...
            '    if len(d) == 1:'  % one variable, single solution
            '        return d[0].popitem()[1],'
            '    else:'  % one variable, multiple solutions
            '        return sp.Matrix([r.popitem()[1] for r in d]),'
            'if len(d) == 1:'
            '    d = d[0]'
            'return d,' ];

    out = pycall_sympy__ (cmd, varargin{:});

    varargout = {out};

  else  % multiple outputs
    cmd = [ cmd
            'd = sp.solve(eqs, *symbols, set=True)'
            'if not isinstance(d, (list, tuple)):'  % https://github.com/sympy/sympy/issues/11661
            '    return d,'
            '(vars, solns) = d'
            'q = []'
            'for (i, var) in enumerate(vars):'
            '    q.append(sp.Matrix([t[i] for t in solns]))'
            'return q,' ];

    out = pycall_sympy__ (cmd, varargin{:});

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

%!shared x,y,eq
%! syms x y
%! eq = 10*x == 20*y;
%!test
%! d = solve(eq, x);
%! assert (isequal (d, 2*y))
%!test
%! d = solve(eq, y);
%! assert (isequal (d, x/2))
%!test
%! d = solve(eq);
%! assert (isequal (d, 2*y))

%!shared x,y
%! syms x y

%!test
%! d = solve(2*x - 3*y == 0, x + y == 1);
%! assert (isequal (d.x, sym(3)/5) && isequal(d.y, sym(2)/5))

%!test
%! d = solve(2*x - 3*y == 0, x + y == 1, x, y);
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
%! [X, Y] = solve(2*x + y == 5, x + y == 3);
%! assert (isequal (X, 2))
%! assert (isequal (Y, 1))

%!test
%! % system: vector of equations, vector of vars
%! [X, Y] = solve([2*x + y == 5, x + y == 3], [x y]);
%! assert (isequal (X, 2))
%! assert (isequal (Y, 1))

%!test
%! % system: vector of equations, individual vars
%! [X, Y] = solve([2*x + y == 5, x + y == 3], x, y);
%! assert (isequal (X, 2))
%! assert (isequal (Y, 1))

%!test
%! % system: individual equations, vector of vars
%! [X, Y] = solve(2*x + y == 5, x + y == 3, [x y]);
%! assert (isequal (X, 2))
%! assert (isequal (Y, 1))

%!test
%! % Multiple outputs with multiple solns
%! [X, Y] = solve(x*x == 4, x == 2*y);
%! assert ((isequal (X, [2; -2]) && isequal (Y, [1; -1])) || ...
%!         (isequal (X, [-2; 2]) && isequal (Y, [-1; 1])))

%!test
%! % Multiple outputs with multiple solns, specify vars
%! [X, Y] = solve(x*x == 4, x == 2*y, x, y);
%! assert ((isequal (X, [2; -2]) && isequal (Y, [1; -1])) || ...
%!         (isequal (X, [-2; 2]) && isequal (Y, [-1; 1])))

%!error
%! % mult outputs not allowed for scalar equation, even with mult soln (?)
%! [s1, s2] = solve(x^2 == 4, x);

%!test
%! % overdetermined
%! X = solve(2*x - 10 == 0, 3*x - 15 == 0, x);
%! assert (isequal (X, sym(5)))

%!test
%! a = solve(2*x >= 10, 10*x <= 50);
%! assert (isequal( a, x==sym(5)))

%!test
%! A = solve([2*x == 4*y, 2 == 3], x);
%! if (pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%!   assert (isempty (A))
%! else
%!   assert (isequal (A, sym(false)))
%! end

%!test
%! % Issue #850
%! A = solve (sym(pi)^2*x + y == 0);
%! assert (isequal (A, -y/sym(pi)^2))

%!test
%! % https://github.com/sympy/sympy/issues/14632
%! A = solve([2*x == 4*y, sym(2) == 2], x);
%! assert (isequal (A, 2*y))

%!test
%! % https://github.com/sympy/sympy/issues/14632
%! A = solve([2*x^2 == 32*y^2, sym(2) == 2], x);
%! B = solve([2*x^2 == 32*y^2], x);
%! assert (isequal (A, B) || isequal (A, flip (B)))

%!test
%! A = solve ([x+1 0], x);
%! assert (isequal (A, sym (-1)))

%!test
%! A = solve (x + 1, x);
%! assert (isequal (A, sym (-1)))
%! A = solve (x, x);
%! assert (isequal (A, sym (0)))
