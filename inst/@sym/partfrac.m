%% Copyright (C) 2014, 2015 Colin B. Macdonald, Andrés Prieto
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
%% @deftypefn {Function File} {@var{g} =} partfrac (@var{f})
%% @deftypefnx {Function File} {@var{g} =} partfrac (@var{f}, @var{x})
%% Compute partial fraction decomposition of a rational function.
%%
%% Examples:
%% @example
%% syms x
%% f = 2/(x + 4)/(x + 1)
%% partfrac(f)
%% partfrac(f, x)
%% @end example
%%
%% Other examples:
%% @example
%% partfrac(y/(x + y)/(x + 1), x)
%% partfrac(y/(x + y)/(x + 1), y)
%% @end example
%%
%% @seealso{factor}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, fractions

function z = partfrac(f, x)

  % some special cases for SMT compat.
  if (nargin == 1)
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');
    end
  end

  cmd = 'return sp.polys.partfrac.apart(_ins[0],_ins[1]),';

  z = python_cmd (cmd, sym(f), sym(x));

end


%!test
%! % basic
%! syms x y z
%! assert(logical( partfrac(y/(x + 2)/(x + 1),x) == -y/(x + 2) + y/(x + 1) ))
%! assert(logical( factor(partfrac(x^2/(x^2 - y^2),y)) == factor(x/(2*(x + y)) + x/(2*(x - y)) )))
%! assert(logical( factor(partfrac(x^2/(x^2 - y^2),x)) == factor(-y/(2*(x + y)) + y/(2*(x - y)) + 1 )))
