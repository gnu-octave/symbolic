%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {[@var{A}, @var{b}] =} equationsToMatrix (@var{eqns}, @var{vars})
%% @deftypemethodx @@sym {[@var{A}, @var{b}] =} equationsToMatrix (@var{eqns})
%% @deftypemethodx @@sym {[@var{A}, @var{b}] =} equationsToMatrix (@var{eq1}, @var{eq2}, @dots{})
%% @deftypemethodx @@sym {[@var{A}, @var{b}] =} equationsToMatrix (@var{eq1}, @dots{}, @var{v1}, @var{v2}, @dots{})
%% Convert set of linear equations to matrix form.
%%
%% In its simplest form, equations @var{eq1}, @var{eq2}, etc can be
%% passed as inputs:
%% @example
%% @group
%% syms x y z
%% [A, b] = equationsToMatrix (x + y == 1, x - y + 1 == 0)
%%   @result{} A = (sym 2×2 matrix)
%%
%%       ⎡1  1 ⎤
%%       ⎢     ⎥
%%       ⎣1  -1⎦
%%
%%   @result{} b = (sym 2×1 matrix)
%%
%%       ⎡1 ⎤
%%       ⎢  ⎥
%%       ⎣-1⎦
%% @end group
%% @end example
%% In this case, appropriate variables @emph{and their ordering} will be
%% determined automatically using @code{symvar} (@pxref{@@sym/symvar}).
%%
%% In some cases it is important to specify the variables as additional
%% inputs @var{v1}, @var{v2}, etc:
%% @example
%% @group
%% syms a
%% [A, b] = equationsToMatrix (a*x + y == 1, y - x == a)
%%   @print{} ??? ... nonlinear...
%%
%% [A, b] = equationsToMatrix (a*x + y == 1, y - x == a, x, y)
%%   @result{} A = (sym 2×2 matrix)
%%
%%       ⎡a   1⎤
%%       ⎢     ⎥
%%       ⎣-1  1⎦
%%
%%   @result{} b = (sym 2×1 matrix)
%%
%%       ⎡1⎤
%%       ⎢ ⎥
%%       ⎣a⎦
%% @end group
%% @end example
%%
%% The equations and variables can also be passed as vectors @var{eqns}
%% and @var{vars}:
%% @example
%% @group
%% eqns = [x + y - 2*z == 0, x + y + z == 1, 2*y - z + 5 == 0];
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% [A, B] = equationsToMatrix (eqns, [x y])
%%   @result{} A = (sym 3×2 matrix)
%%
%%       ⎡1  1⎤
%%       ⎢    ⎥
%%       ⎢1  1⎥
%%       ⎢    ⎥
%%       ⎣0  2⎦
%%
%%   B = (sym 3×1 matrix)
%%
%%       ⎡ 2⋅z ⎤
%%       ⎢     ⎥
%%       ⎢1 - z⎥
%%       ⎢     ⎥
%%       ⎣z - 5⎦
%% @end group
%% @end example
%% @seealso{@@sym/solve}
%% @end deftypemethod


function [A, b] = equationsToMatrix(varargin)

  % when Symbols are specified, this won't be used
  s = findsymbols (varargin);

  cmd = {'L, symvars = _ins'
         'if not isinstance(L[-1], MatrixBase):'
         '    if isinstance(L[-1], Symbol):'  % Symbol given, fill vars...
         '        vars = list()'
         '        for i in reversed(range(len(L))):'
         '            if isinstance(L[i], Symbol):'
         '                vars = [L.pop(i)] + vars'
         '            else:'  % ... until we find a non-Symbol
         '                break'
         '    else:'
         '        vars = symvars'
         'else:'
         '    if len(L) == 1:'  % we have only a list of equations
         '        vars = symvars'
         '    else:'
         '        vars = L.pop(-1)'
         'if Version(spver) > Version("1.3"):'
         '    if len(L) == 1:'  % might be matrix of eqns, don't want [Matrix]
         '        L = L[0]'
         '    vars = list(vars)'
         '    A, B = linear_eq_to_matrix(L, vars)'
         '    return True, A, B'
         '#'
         '# sympy <= 1.3: we do the work ourselves'
         '#'
         'vars = list(collections.OrderedDict.fromkeys(vars))' %% Never repeat elements
         'if len(L) == 1 and isinstance(L[0], MatrixBase):'
         '    L = [a for a in L[0]]'
         'if len(L) == 0 or len(vars) == 0:'
         '    return True, Matrix([]), Matrix([])'
         'A = zeros(len(L), len(vars)); b = zeros(len(L), 1)'
         'for i in range(len(L)):'
         '    q = L[i]'
         '    for j in range(len(vars)):'
         '        p = Poly.from_expr(L[i], vars[j]).all_coeffs()'
         '        q = Poly.from_expr(q, vars[j]).all_coeffs()'
         '        if len(p) > 2:'
         '            return False, 0, 0'
         '        p = p[0] if len(p) == 2 else S(0)'
         '        q = q[1] if len(q) == 2 else q[0]'
         '        if not set(p.free_symbols).isdisjoint(set(vars)):'
         '            return False, 0, 0'
         '        A[i, j] = p'
         '    b[i] = -q'
         'return True, A, b' };

  for i = 1:length(varargin)
    varargin{i} = sym (varargin{i});
  end

  [s, A, b] = pycall_sympy__ (cmd, varargin, s);


  if ~s
    error('Cannot convert to matrix; system may be nonlinear.');
  end

end


%!test
%! syms x y z
%! [A, B] = equationsToMatrix ([x + y - z == 1, 3*x - 2*y + z == 3, 4*x - 2*y + z + 9 == 0], [x, y, z]);
%! a = sym ([1 1 -1; 3 -2 1; 4 -2 1]);
%! b = sym ([1; 3; -9]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! syms x y z
%! A = equationsToMatrix ([3*x + -3*y - 5*z == 9, 4*x - 7*y + -3*z == -1, 4*x - 9*y - 3*z + 2 == 0], [x, y, z]);
%! a = sym ([3 -3 -5; 4 -7 -3; 4 -9 -3]);
%! assert (isequal (A, a))

%!test
%! syms x y
%! [A, B] = equationsToMatrix ([3*x + 9*y - 5 == 0, -8*x - 3*y == -2]);
%! a = sym ([3 9; -8 -3]);
%! b = sym ([5; -2]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! % override symvar order
%! syms x y
%! [A, B] = equationsToMatrix ([3*x + 9*y - 5 == 0, -8*x - 3*y == -2], [y x]);
%! a = sym ([9 3; -3 -8]);
%! b = sym ([5; -2]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! syms x y z
%! [A, B] = equationsToMatrix ([x - 9*y + z == -5, -9*y*z == -5], [y, x]);
%! a = sym ([[-9 1]; -9*z 0]);
%! b = sym ([-5 - z; -5]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! syms x y
%! [A, B] = equationsToMatrix (-6*x + 4*y == 5, 4*x - 4*y - 5, x, y);
%! a = sym ([-6 4; 4 -4]);
%! b = sym ([5; 5]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! % vertical list of equations
%! syms x y
%! [A, B] = equationsToMatrix ([-6*x + 4*y == 5; 4*x - 4*y - 5], [x y]);
%! a = sym ([-6 4; 4 -4]);
%! b = sym ([5; 5]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! syms x y
%! [A, B] = equationsToMatrix (5*x == 1, y, x - 6*y - 7, y);
%! a = sym ([0; 1; -6]);
%! b = sym ([1 - 5*x; 0; -x + 7]);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!error <nonlinear>
%! syms x y
%! [A, B] = equationsToMatrix (x^2 + y^2 == 1, x - y + 1, x, y);

%!test
%! % single equation
%! syms x
%! [A, B] = equationsToMatrix (3*x == 2, x);
%! a = sym (3);
%! b = sym (2);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!test
%! % single equation w/ symvar
%! syms x
%! [A, B] = equationsToMatrix (3*x == 2);
%! a = sym (3);
%! b = sym (2);
%! assert (isequal (A, a))
%! assert (isequal (B, b))

%!error <unique>
%! if (pycall_sympy__ ('return Version(spver) <= Version("1.3")'))
%!   error ('unique')
%! end
%! syms x
%! equationsToMatrix (3*x == 2, [x x])
