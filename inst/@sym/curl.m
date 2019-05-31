%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym curl (@var{F})
%% @defmethodx @@sym curl (@var{F}, @var{x})
%% Symbolic curl of symbolic expression.
%%
%% Consider a vector expression @var{F}:
%% @example
%% @group
%% syms f(x,y,z) g(x,y,z) h(x,y,z)
%% F = [f; g; h]
%%   @result{} F = (sym 3×1 matrix)
%%       ⎡f(x, y, z)⎤
%%       ⎢          ⎥
%%       ⎢g(x, y, z)⎥
%%       ⎢          ⎥
%%       ⎣h(x, y, z)⎦
%% @end group
%% @end example
%% The curl of @var{F} is the vector expression:
%% @example
%% @group
%% curl(F)
%%   @result{} (sym 3×1 matrix)
%%       ⎡  ∂                ∂             ⎤
%%       ⎢- ──(g(x, y, z)) + ──(h(x, y, z))⎥
%%       ⎢  ∂z               ∂y            ⎥
%%       ⎢                                 ⎥
%%       ⎢ ∂                ∂              ⎥
%%       ⎢ ──(f(x, y, z)) - ──(h(x, y, z)) ⎥
%%       ⎢ ∂z               ∂x             ⎥
%%       ⎢                                 ⎥
%%       ⎢  ∂                ∂             ⎥
%%       ⎢- ──(f(x, y, z)) + ──(g(x, y, z))⎥
%%       ⎣  ∂y               ∂x            ⎦
%% @end group
%% @end example
%%
%% @var{F} and @var{x} should be vectors of length three.
%% If omitted, @var{x} is determined using @code{symvar}.
%%
%% Example:
%% @example
%% @group
%% syms x y z
%% F = [y -x 0];
%% curl(F, @{x y z@})
%%   @result{} (sym 3×1 matrix)
%%       ⎡0 ⎤
%%       ⎢  ⎥
%%       ⎢0 ⎥
%%       ⎢  ⎥
%%       ⎣-2⎦
%% @end group
%% @end example
%%
%% Example verifying an identity:
%% @example
%% @group
%% syms f(x, y, z)
%% curl(gradient(f))
%%   @result{} (sym 3×1 matrix)
%%       ⎡0⎤
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎣0⎦
%% @end group
%% @end example
%%
%% Note: assumes @var{x} is a Cartesian coordinate system.
%%
%% @seealso{@@sym/divergence, @@sym/gradient, @@sym/laplacian, @@sym/jacobian,
%%          @@sym/hessian}
%% @end defmethod


function g = curl(v,x)

  assert(isvector(v) && length(v)==3, 'curl is for 3D vector fields')

  if (nargin == 1)
    x = symvar(v, 3);
  elseif (nargin == 2)
    % no-op
  else
    print_usage ();
  end
  assert(length(x)==3, 'coordinate system should have three components')

  % ugh issue 17 so do in python to avoid

  cmd = { '(v, x) = _ins'
          'def d(u, y):'
          '    if u.is_constant():'  % FIXME ?
          '        return sp.numbers.Zero()'
          '    return u.diff(y)'
          'g = Matrix([ \'
          '      d(v[2], x[1]) - d(v[1], x[2]),  \'
          '      d(v[0], x[2]) - d(v[2], x[0]),  \'
          '      d(v[1], x[0]) - d(v[0], x[1])  ])'
          'return g,' };

  g = pycall_sympy__ (cmd, sym(v), x);

end


%!shared x,y,z
%! syms x y z

%!test
%! % double const
%! f = [1 2 3];
%! g = [sym(0); 0; 0];
%! assert (isequal (curl(f, [x y z]), g))
%! % should fail, calls @double: curl(f, {x y z}), g))

%!test
%! % div curl always 0
%! v = [exp(x); x*y; sin(z)];
%! g = curl(v);
%! a = divergence(g, [x y z]);
%! assert (isAlways (a == sym(0)))
%! assert (isa (a, 'sym'))
%! g = curl(v, [x y z]);
%! a = divergence(g, [x y z]);
%! assert (isAlways (a == sym(0)))
%! assert (isa (a, 'sym'))

%!test
%! % div curl always 0
%! v = [exp(x); erfc(x*y); sin(exp(x)*y+sinh(z))];
%! g = curl(v, [x y z]);
%! a = divergence(g, [x y z]);
%! assert (isAlways (a == sym(0)))
%! assert (isa (a, 'sym'))

%!test
%! % curl grad is vec zero
%! f = sin(exp(x)*y+sinh(z));
%! g = curl(gradient(f, [x,y,z]));
%! assert (isequal (g, sym([0;0;0])))

%!test
%! % 2d fcn in 2d/3d
%! u = sin(exp(x)*y);
%! v = x^2*y^3;
%! vorticity2d = diff(v,x) - diff(u,y);
%! omega = curl([u; v; 0], [x y z]);
%! assert (isequal (omega, [0; 0; vorticity2d]))

%!error <3D vector> curl([sym(1) 2 3 4])
%!error <three components> curl([sym(1) 2 3], {sym('x') sym('y') sym('z') sym('t')})
%!error <Invalid> curl([sym(1) 2 3], 42, 42)
