%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym potential (@var{v})
%% @defmethodx @@sym potential (@var{v}, @var{x})
%% @defmethodx @@sym potential (@var{v}, @var{x}, @var{y})
%% Symbolic potential of a vector field.
%%
%% Finds the potential of the vector field @var{v} with respect to
%% the variables @var{x}$.  The potential is defined up to an
%% additive constant, unless the third argument is given; in which
%% case the potential is such that @var{p} is zero at the point
%% @var{y}.
%%
%% Example:
%% @example
%% @group
%% syms x y z
%% f = x*y*z;
%% g = gradient (f)
%%  @result{} g = (sym 3×1 matrix)
%%      ⎡y⋅z⎤
%%      ⎢   ⎥
%%      ⎢x⋅z⎥
%%      ⎢   ⎥
%%      ⎣x⋅y⎦
%% potential (g)
%%  @result{} (sym) x⋅y⋅z
%% @end group
%% @end example
%%
%% Return symbolic @code{nan} if the field has no potential (based
%% on checking if the Jacobian matrix of the field is
%% nonsymmetric).  For example:
%% @example
%% @group
%% syms x y
%% a = [x; x*y^2];
%% potential (a)
%%  @result{} (sym) nan
%% @end group
%% @end example
%%
%% @seealso{@@sym/gradient, @@sym/jacobian}
%% @end defmethod


function p = potential(v, x, y)

  if (nargin > 3)
    print_usage ();
  end

  assert (isvector(v), 'potential: defined for vector fields')

  if (nargin == 1)
    x = symvar(v);
  end

  % orient same as vec field
  x = reshape(x, size(v));

  if (nargin < 3)
    y = 0*x;
  end

  assert ((length(v) == length(x)) && (length(x) == length(y)), ...
          'potential: num vars must match vec length')

  cmd = { '(v, x, y) = _ins'
          'if not v.is_Matrix:'
          '    v = Matrix([v])'
          '    x = Matrix([x])'
          '    y = Matrix([y])'
          'G = v.jacobian(x)'
          'if not G.is_symmetric():'
          '    return S.NaN,'
          '_lambda = sympy.Dummy("lambda", real=True)'
          'q = y + _lambda*(x - y)'
          'vlx = v.subs(list(zip(list(x), list(q))), simultaneous=True)'
          'p = integrate((x-y).dot(vlx), (_lambda, 0, 1))'
          'return p.simplify(),' };

  p = pycall_sympy__ (cmd, sym(v), x, sym(y));

end


%!error <Invalid> potential (sym(1), 2, 3, 4)

%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = 3*x^2;
%! F = x^3;
%! assert (isequal (potential(f), F))
%! assert (isequal (potential(f, x), F))
%! assert (isequal (potential(f, x, 0), F))
%! assert (isequal (potential(f, x, 2), F - 8))

%!test
%! F = x*exp(y) + (z-1)^2;
%! f = gradient(F);
%! G = potential(f, [x;y;z], [0;1;1]);
%! assert (isAlways (G == F))

%!test
%! F = x*exp(y);
%! f = gradient(F);
%! G = potential(f);
%! assert (isAlways (G == F))

%!test
%! % no potential exists
%! syms x y
%! a = [x; x*y^2];
%! assert (isnan (potential (a)))


%!shared

%!xtest
%! % fails b/c of sympy #8458 (piecewise expr that should simplify)
%! syms x
%! f = cos(x);
%! assert (isequal (potential(f, x), sin(x)))
