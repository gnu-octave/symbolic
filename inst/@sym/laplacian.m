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
%% @defmethod  @@sym laplacian (@var{f})
%% @defmethodx @@sym laplacian (@var{f}, @var{x})
%% Symbolic Laplacian of symbolic expression.
%%
%% The Laplacian of a scalar expression @var{f} is
%% the scalar expression:
%% @example
%% @group
%% syms f(x, y, z)
%% laplacian(f)
%%   @result{} (sym)
%%         2                 2                 2
%%        ∂                 ∂                 ∂
%%       ───(f(x, y, z)) + ───(f(x, y, z)) + ───(f(x, y, z))
%%         2                 2                 2
%%       ∂x                ∂y                ∂z
%% @end group
%% @end example
%%
%% @var{x} can be a scalar, vector or cell list.  If omitted,
%% it is determined using @code{symvar}.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% laplacian(x^3 + 5*y^2)
%%   @result{} (sym) 6⋅x + 10
%% @end group
%% @end example
%%
%% Note: assumes @var{x} is a Cartesian coordinate system.
%%
%% @seealso{@@sym/divergence, @@sym/gradient, @@sym/curl, @@sym/jacobian,
%%          @@sym/hessian}
%% @end defmethod


function g = laplacian(f,x)

  assert (isscalar(f), 'laplacian: only scalar functions supported')

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
          'g = 0'
          'for y in x:'
          '    g = g + f.diff(y, 2)'
          'return g,' };

  g = pycall_sympy__ (cmd, sym(f), x);

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
%! % double const
%! f = 1;
%! g = sym(0);
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

%!error laplacian(sym('x'), sym('x'), 42)
%!error <only scalar> laplacian([sym('x'), sym('x')])
