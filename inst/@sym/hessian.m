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
%% @deftypefn  {Function File} {@var{H} =} hessian (@var{f})
%% @deftypefnx {Function File} {@var{H} =} hessian (@var{f}, @var{x})
%% Symbolic Hessian matrix of symbolic scalar expression.
%%
%% @var{x} can be a scalar, vector or cell list.  If omitted,
%% it is determined using @code{symvar}.
%%
%% @seealso{jacobian, divergence, gradient, curl, laplacian}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function H = hessian(f,x)

  assert (isscalar(f), 'hessian: defined for scalar functions')

  if (nargin == 1)
    x = symvar(f);
    if (isempty(x))
      x = sym('x');
    end
  end

  if (~iscell(x) && isscalar(x))
    x = {x};
  end

  cmd = [ '(f,x,) = _ins\n'  ...
          '#if not f.is_Matrix:\n' ...
          'f = Matrix([f])\n' ...
          'grad = f.jacobian(x).T\n' ...
          'H = grad.jacobian(x)\n' ...
          'return ( H ,)' ];

  H = python_cmd (cmd, sym(f), x);

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

