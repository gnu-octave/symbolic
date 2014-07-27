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
%% @deftypefn  {Function File} {@var{G} =} laplacian (@var{f})
%% @deftypefnx {Function File} {@var{G} =} laplacian (@var{f}, @var{x})
%% Symbolic laplacian of symbolic expression.
%%
%% @var{x} can be a scalar, vector or cell list.  If omitted,
%% it is determined using @code{symvar}.
%%
%% Note: assumes @var{x} is a Cartesian coordinate system.
%%
%% @seealso{divergence, gradient, curl, jacobian, hessian}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function g = laplacian(f,x)

  assert (isscalar(f), 'laplacian: only scalar functions supported')

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
          'g = 0\n'...
          'for y in x:\n' ...
          '    g = g + f.diff(y,2)\n' ...
          'return ( g ,)' ];

  g = python_cmd (cmd, f, x);

end


%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = x^2;
%! g = diff(f,x,x);
%! assert (isequal (laplacian(f), g))
%! assert (isequal (laplacian(f,{x}), g))
%! assert (isequal (laplacian(f,[x]), g))
%! assert (isequal (laplacian(f,x), g))

%!test
%! % const
%! f = sym(1);
%! g = sym(0);
%! assert (isequal (laplacian(f), g))
%! assert (isequal (laplacian(f,x), g))
%! f = sym('c');
%! assert (isequal (laplacian(f,x), g))

%!test
%! % 1D fcn in 2d/3d
%! f = sin(2*y);
%! g = -4*f;
%! assert (isequal (laplacian(f), g))
%! assert (isequal (laplacian(f, {x,y}), g))
%! assert (isequal (laplacian(f, {x,y,z}), g))

%!test
%! % 2d fcn in 2d/3d
%! f = sin(exp(x)*y);
%! g = diff(f,x,x) + diff(f,y,y);
%! assert (isequal (laplacian(f), g))
%! assert (isequal (laplacian(f, {x,y}), g))

%!test
%! % 2d fcn in 2d/3d
%! f = sin(exp(x)*y+sinh(z));
%! gr2 = gradient(f, {x,y});
%! divgr2 = divergence(gr2, {x,y});
%! l2 = laplacian(f,{x,y});
%! gr3 = gradient(f, {x,y,z});
%! divgr3 = divergence(gr3, {x,y,z});
%! l3 = laplacian(f,{x,y,z});
%! assert (isAlways (l2 == divgr2))
%! assert (isAlways (l3 == divgr3))

