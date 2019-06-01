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
%% @defmethod  @@sym gradient (@var{f})
%% @defmethodx @@sym gradient (@var{f}, @var{x})
%% Symbolic gradient of symbolic expression.
%%
%% The gradient of scalar expression is the vector
%% @example
%% @group
%% syms f(x, y, z)
%% gradient(f)
%%   @result{} (sym 3×1 matrix)
%%       ⎡∂             ⎤
%%       ⎢──(f(x, y, z))⎥
%%       ⎢∂x            ⎥
%%       ⎢              ⎥
%%       ⎢∂             ⎥
%%       ⎢──(f(x, y, z))⎥
%%       ⎢∂y            ⎥
%%       ⎢              ⎥
%%       ⎢∂             ⎥
%%       ⎢──(f(x, y, z))⎥
%%       ⎣∂z            ⎦
%% @end group
%% @end example
%%
%% Example:
%% @example
%% @group
%% f = x^3 + 5*y^2;
%% gradient(f)
%%   @result{} (sym 2×1 matrix)
%%       ⎡   2⎤
%%       ⎢3⋅x ⎥
%%       ⎢    ⎥
%%       ⎣10⋅y⎦
%% @end group
%% @end example
%%
%% @var{x} can be a scalar, vector or cell list.  If omitted,
%% it is determined using @code{symvar}.  Example:
%% @example
%% @group
%% gradient(f, @{x y z@})
%%   @result{} (sym 3×1 matrix)
%%       ⎡   2⎤
%%       ⎢3⋅x ⎥
%%       ⎢    ⎥
%%       ⎢10⋅y⎥
%%       ⎢    ⎥
%%       ⎣ 0  ⎦
%% @end group
%% @end example
%%
%% Note: assumes @var{x} is a Cartesian coordinate system.
%%
%% @seealso{@@sym/divergence, @@sym/curl, @@sym/laplacian, @@sym/jacobian,
%%          @@sym/hessian}
%% @end defmethod


function g = gradient(f,x)

  assert (isscalar(f), 'gradient: defined only for scalar functions')

  if (nargin == 1)
    x = symvar(f);
    if (isempty(x))
      x = sym('x');
    end
  elseif (nargin == 2)
    % no-op
  else
    print_usage ();
  end

  if (~iscell(x) && isscalar(x))
    x = {x};
  end

  cmd = { '(f, x) = _ins'
          'if not f.is_Matrix:'
          '    f = Matrix([f])'
          'G = f.jacobian(x).T'
          'return G,' };

  g = pycall_sympy__ (cmd, sym(f), x);

end


%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = x^2;
%! assert (isequal (gradient(f), diff(f,x)))
%! assert (isequal (gradient(f,{x}), diff(f,x)))
%! assert (isequal (gradient(f,[x]), diff(f,x)))
%! assert (isequal (gradient(f,x), diff(f,x)))

%!test
%! % const
%! f = sym(1);
%! g = sym(0);
%! assert (isequal (gradient(f), g))
%! assert (isequal (gradient(f,x), g))

%!test
%! % double const
%! f = 1;
%! g = sym(0);
%! assert (isequal (gradient(f,x), g))

%!test
%! % 1D fcn in 2d/3d
%! f = sin(y);
%! assert (isequal (gradient(f), diff(f,y)))
%! assert (isequal (gradient(f, {x,y}), [sym(0); diff(f,y)]))
%! assert (isequal (gradient(f, [x y]), [sym(0); diff(f,y)]))
%! assert (isequal (size (gradient(f, {x,y})), [2 1]))
%! assert (isequal (gradient(f, {x,y,z}), [0; diff(f,y); 0]))
%! assert (isequal (gradient(f, [x y z]), [0; diff(f,y); 0]))
%! assert (isequal (size (gradient(f, {x,y,z})), [3 1]))

%!test
%! % grad is column vector
%! f = sin(y);
%! assert (isequal (size (gradient(f, {x,y})), [2 1]))
%! assert (isequal (size (gradient(f, {x,y,z})), [3 1]))
%! assert (isequal (size (gradient(f, [x y])), [2 1]))
%! assert (isequal (size (gradient(f, [x;y])), [2 1]))

%!test
%! % 2d fcn in 2d/3d
%! f = sin(exp(x)*y);
%! g2 = [diff(f,x); diff(f,y)];
%! g3 = [diff(f,x); diff(f,y); diff(f,z)];
%! assert (isequal (gradient(f), g2))
%! assert (isequal (gradient(f, {x,y}), g2))
%! assert (isequal (gradient(f, {x,y,z}), g3))

%!test
%! % 2d fcn in 2d/3d
%! f = sin(exp(x)*y+sinh(z));
%! g2 = [diff(f,x); diff(f,y)];
%! g3 = [diff(f,x); diff(f,y); diff(f,z)];
%! assert (isequal (gradient(f), g3))
%! assert (isequal (gradient(f, {x,y}), g2))
%! assert (isequal (gradient(f, {x,y,z}), g3))

%!error gradient(sym('x'), 42, 42)
%!error <only for scalar> gradient([sym('x') sym('x')])
