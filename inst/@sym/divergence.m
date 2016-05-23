%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod  @@sym divergence (@var{F})
%% @defmethodx @@sym divergence (@var{F}, @var{x})
%% Symbolic divergence of symbolic expression.
%%
%% Consider a vector expression @var{F}:
%% @example
%% @group
%% syms f_1(x,y,z) f_2(x,y,z) f_3(x,y,z)
%% F = [f_1; f_2; f_3]
%%   @result{} F = (sym 3×1 matrix)
%%       ⎡f₁(x, y, z)⎤
%%       ⎢           ⎥
%%       ⎢f₂(x, y, z)⎥
%%       ⎢           ⎥
%%       ⎣f₃(x, y, z)⎦
%% @end group
%% @end example
%% The divergence of @var{F} is the scalar expression:
%% @example
%% @group
%% divergence(F)
%%   @result{} (sym)
%%       ∂                 ∂                 ∂
%%       ──(f₁(x, y, z)) + ──(f₂(x, y, z)) + ──(f₃(x, y, z))
%%       ∂x                ∂y                ∂z
%% @end group
%% @end example
%%
%% Examples:
%% @example
%% @group
%% syms x y
%% F = [x^2/2  y^2/2];
%% divergence(F)
%%   @result{} (sym) x + y
%% @end group
%%
%% @group
%% syms z
%% F = [y x x*y];
%% divergence(F, [x; y; z])
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% Note: assumes @var{x} is a Cartesian coordinate system.
%%
%% @seealso{@@sym/gradient, @@sym/curl, @@sym/laplacian, @@sym/jacobian,
%%          @@sym/hessian}
%% @end defmethod

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function g = divergence(f, x)

  assert (isvector(f), 'divergence: defined for vectors')

  if (nargin == 1)
    x = symvar(f);
  elseif (nargin == 2)
    % np-op
  else
    print_usage ();
  end

  assert (length(f) == length(x), 'divergence: num vars must match vec length')

  idx1.type='()';
  if (iscell(x))
    idx2.type='{}';
  else
    idx2.type='()';
  end
  g = sym(0);
  for i = 1:length(f)
    idx1.subs={i};
    idx2.subs={i};
    g = g + diff (subsref(f,idx1), subsref(x,idx2));
  end

end


%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = x^2;
%! assert (isequal (divergence(f), diff(f,x)))
%! assert (isequal (divergence(f,{x}), diff(f,x)))
%! assert (isequal (divergence(f,[x]), diff(f,x)))
%! assert (isequal (divergence(f,x), diff(f,x)))

%!test
%! % const
%! f = [sym(1); 2; exp(sym(3))];
%! assert (isequal (divergence(f,{x,y,z}), 0))
%! f = [sym(1); 2; exp(sym('c'))];
%! assert (isequal (divergence(f,{x,y,z}), 0))

%!test
%! % double const
%! f = [1 2];
%! g = sym(0);
%! assert (isequal (divergence(f, [x y]), g))
%! % should fail, calls @double: divergence(f, {x y}), g))

%!test
%! % 1D fcn in 2d/3d
%! f = [x y z];
%! assert (isequal (divergence(f), 3))
%! assert (isequal (divergence(f, {x,y,z}), 3))
%! assert (isequal (divergence(f, [x,y,z]), 3))

%!test
%! % 2d fcn in 2d/3d
%! f = sin(exp(x)*y+sinh(z));
%! g2 = [diff(f,x); diff(f,y)];
%! l2 = diff(g2(1),x) + diff(g2(2),y);
%! g3 = [diff(f,x); diff(f,y); diff(f,z)];
%! l3 = diff(g3(1),x) + diff(g3(2),y) + diff(g3(3),z);
%! assert (isequal (divergence(g2, {x,y}), l2))
%! assert (isequal (divergence(g3, {x,y,z}), l3))

%!error divergence ([1 2], [sym('x')])
%!error divergence ([1 2], sym('x'), 42)
