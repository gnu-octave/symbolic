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
%% @defmethod  @@sym hessian (@var{f})
%% @defmethodx @@sym hessian (@var{f}, @var{x})
%% Symbolic Hessian matrix of symbolic scalar expression.
%%
%% The Hessian of a scalar expression @var{f} is the matrix consisting
%% of second derivatives:
%% @example
%% @group
%% syms f(x, y, z)
%% hessian(f)
%%   @result{} (sym 3×3 matrix)
%%     ⎡   2                  2                  2             ⎤
%%     ⎢  ∂                  ∂                  ∂              ⎥
%%     ⎢ ───(f(x, y, z))   ─────(f(x, y, z))  ─────(f(x, y, z))⎥
%%     ⎢   2               ∂y ∂x              ∂z ∂x            ⎥
%%     ⎢ ∂x                                                    ⎥
%%     ⎢                                                       ⎥
%%     ⎢   2                  2                  2             ⎥
%%     ⎢  ∂                  ∂                  ∂              ⎥
%%     ⎢─────(f(x, y, z))   ───(f(x, y, z))   ─────(f(x, y, z))⎥
%%     ⎢∂y ∂x                 2               ∂z ∂y            ⎥
%%     ⎢                    ∂y                                 ⎥
%%     ⎢                                                       ⎥
%%     ⎢   2                  2                  2             ⎥
%%     ⎢  ∂                  ∂                  ∂              ⎥
%%     ⎢─────(f(x, y, z))  ─────(f(x, y, z))   ───(f(x, y, z)) ⎥
%%     ⎢∂z ∂x              ∂z ∂y                 2             ⎥
%%     ⎣                                       ∂z              ⎦
%% @end group
%% @end example
%%
%% @var{x} can be a scalar, vector or cell list.  If omitted,
%% it is determined using @code{symvar}.
%%
%% Example:
%% @example
%% @group
%% f = x*y;
%% hessian(f)
%%   @result{} (sym 2×2 matrix)
%%       ⎡0  1⎤
%%       ⎢    ⎥
%%       ⎣1  0⎦
%% @end group
%% @end example
%% @seealso{@@sym/jacobian, @@sym/divergence, @@sym/gradient, @@sym/curl,
%%          @@sym/laplacian}
%% @end defmethod


function H = hessian(f, x)

  assert (isscalar(f), 'hessian: defined only for scalar functions')

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

  cmd = { '(f,x,) = _ins'
          '#if not f.is_Matrix:'
          'f = Matrix([f])'
          'grad = f.jacobian(x).T'
          'H = grad.jacobian(x)'
          'return H,' };

  H = pycall_sympy__ (cmd, sym(f), x);

end


%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = x^2;
%! assert (isequal (hessian(f), diff(f,x,x)))
%! assert (isequal (hessian(f,{x}), diff(f,x,x)))
%! assert (isequal (hessian(f,x), diff(f,x,x)))

%!test
%! % const
%! f = sym(1);
%! g = sym(0);
%! assert (isequal (hessian(f), g))
%! assert (isequal (hessian(f,x), g))

%!test
%! % double const
%! f = 1;
%! g = sym(0);
%! assert (isequal (hessian(f,x), g))

%!test
%! % linear
%! f = 42*x;
%! g = sym(0);
%! assert (isequal (hessian(f), g))
%! assert (isequal (hessian(f,x), g))

%!test
%! % linear
%! f = 42*x - sym('a')*y;
%! g = [0 0; 0 0];
%! assert (isequal (hessian(f, {x y}), g))

%!test
%! % 2d
%! f = x*cos(y);
%! g = [0 -sin(y); -sin(y) -f];
%! assert (isequal (hessian(f), g))
%! assert (isequal (hessian(f, {x y}), g))

%!test
%! % 3d
%! f = x*cos(z);
%! Hexp = [0 0 -sin(z); sym(0) 0 0; -sin(z) 0 -f];
%! H = hessian(f, {x y z});
%! assert (isequal (H, Hexp))

%!error <only for scalar> hessian([sym(1) sym(2)])
%!error <Invalid call> hessian(sym(1), 2, 3)
