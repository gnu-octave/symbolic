%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {@var{x} =} mldivide (@var{A}, @var{b})
%% Symbolic backslash: solve linear systems.
%%
%% Over- and under-determined aystem are supported.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function x = mldivide(A, b)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(A, 'symfun') || isa(b, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    x = mldivide(A, b);
    return
  end

  % not for singular
  %'ans = A.LUsolve(b)'

  if (isscalar(A))
    x = b / A;
    return
  end


  cmd = {
    '(A, B) = _ins'
    'if not A.is_Matrix:'
    '    A = sympy.Matrix([A])'
    'if not B.is_Matrix:'
    '    B = sympy.Matrix([B])'
    'M = A.cols'
    'Z = sympy.zeros(M, B.cols)'
    'for k in range(0, B.cols):'
    '    b = B.col(k)'
    '    x = [Symbol("c%d" % (j + k*M)) for j in range(0, M)]'
    '    #dbout(x)'
    '    AA = A.hstack(A, b)'
    '    d = solve_linear_system(AA, *x)'
    '    if d is None:'
    '        Z[:, k] = sympy.Matrix([S.NaN]*M)'
    '    else:'
    '        # apply dict'
    '        Z[:, k] = sympy.Matrix([d.get(c, c) for c in x])'
    '    #dbout(Z)'
    'return Z,'
  };

  x = python_cmd (cmd, sym(A), sym(b));

end

% [5 2] \ 10

%!test
%! % scalar
%! syms x
%! assert (isa( x\x, 'sym'))
%! assert (isequal( x\x, sym(1)))
%! assert (isa( 2\x, 'sym'))
%! assert (isa( x\2, 'sym'))

%!test
%! % scalar \ matrix: easy, no system
%! D = 2*[0 1; 2 3];
%! A = sym(D);
%! assert (isequal (  2 \ A , D/2  ))
%! assert (isequal (  sym(2) \ A , D/2  ))

%!test
%! % singular matrix
%! A = sym([1 2; 2 4]);
%! b = sym([5; 10]);
%! x = A \ b;
%! syms c1
%! y = [-2*c1 + 5; c1];
%! assert (isequal (x, y))

%!test
%! % singular matrix, mult RHS
%! A = sym([1 2; 2 4]);
%! B = sym([[5; 10] [0; 2] [0; 0]]);
%! x = A \ B;
%! syms c1 c5
%! y = [-2*c1 + 5 nan -2*c5; c1 nan c5];
%! assert (isequaln (x, y))

