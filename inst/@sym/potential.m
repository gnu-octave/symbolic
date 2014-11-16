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
%% @deftypefn  {Function File} {@var{p} =} potential (@var{v})
%% @deftypefnx {Function File} {@var{p} =} potential (@var{v}, @var{x})
%% @deftypefnx {Function File} {@var{p} =} potential (@var{v}, @var{x}, @var{y})
%% Symbolic potential of a vector field.
%%
%% FIXME; DOC
%%
%% @seealso{gradient}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function p = potential(v, x, y)

  assert (isvector(v), 'potential: defined for vector fields')

  if (nargin == 1)
    x = symvar(v);
  end
  if (nargin < 3)
    y = 0*x;
  end

  assert ((length(v) == length(x)) && (length(x) == length(y)), ...
          'potential: num vars must match vec length')

  % orient same as vec field
  x = reshape(x, size(v));

  % FIXME: check jacobian is symmetric?

  cmd = { '(v, x, y) = _ins'
          'if not v.is_Matrix:'
          '    v = Matrix([v])'
          '    x = Matrix([x])'
          '    y = Matrix([y])'
          '_lambda = sympy.Dummy(real=True)'
          'q = y + _lambda*(x - y)'
          'vlx = v.subs(zip(list(x), list(q)))'
          'p = integrate((x-y).dot(vlx), (_lambda, 0, 1))'
          'return p.simplify(),' };

  p = python_cmd (cmd, sym(v), x, sym(y));

end


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

%!xtest
%! % fails b/c of sympy #8458 (piecewise expr that should simplify)
%! f = cos(x);
%! assert (isequal (potential(f, x), sin(x)))

