%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
%% Copyright (C) 2014-2015 Andrés Prieto
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
%% @defmethod  @@sym partfrac (@var{f})
%% @defmethodx @@sym partfrac (@var{f}, @var{x})
%% Compute partial fraction decomposition of a rational function.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% f = 2/(x + 4)/(x + 1)
%%   @result{} f = (sym)
%%              2
%%       ───────────────
%%       (x + 1)⋅(x + 4)
%% @end group
%%
%% @group
%% partfrac(f)
%%   @result{} ans = (sym)
%%             2           2
%%       - ───────── + ─────────
%%         3⋅(x + 4)   3⋅(x + 1)
%% @end group
%% @end example
%%
%% Other examples:
%% @example
%% @group
%% syms x y
%% partfrac(y/(x + y)/(x + 1), x)
%%   @result{} ans = (sym)
%%                y                 y
%%       - ─────────────── + ───────────────
%%         (x + y)⋅(y - 1)   (x + 1)⋅(y - 1)
%% @end group
%%
%% @group
%% partfrac(y/(x + y)/(x + 1), y)
%%   @result{} ans = (sym)
%%                x            1
%%       - ─────────────── + ─────
%%         (x + 1)⋅(x + y)   x + 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/factor}
%% @end defmethod


function z = partfrac(f, x)

  % some special cases for SMT compat.
  if (nargin == 1)
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');
    end
  end

  cmd = 'return sp.polys.partfrac.apart(_ins[0],_ins[1]),';

  z = pycall_sympy__ (cmd, sym(f), sym(x));

end


%!test
%! % basic
%! syms x y z
%! assert(logical( partfrac(y/(x + 2)/(x + 1),x) == -y/(x + 2) + y/(x + 1) ))
%! assert(logical( factor(partfrac(x^2/(x^2 - y^2),y)) == factor(x/(2*(x + y)) + x/(2*(x - y)) )))
%! assert(logical( factor(partfrac(x^2/(x^2 - y^2),x)) == factor(-y/(2*(x + y)) + y/(2*(x - y)) + 1 )))
