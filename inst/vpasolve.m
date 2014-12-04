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
%% @deftypefn  {Function File} {@var{y} =} vpasolve (@var{e})
%% @deftypefnx {Function File} {@var{y} =} vpasolve (@var{e}, @var{x})
%% @deftypefnx {Function File} {@var{y} =} vpasolve (@var{e}, @var{x}, @var{x0})
%% Numerical solution of a symbolic equation.
%%
%% 
%% @example
%% syms x
%% e = exp(x) == x + 2
%% vpa_solve(e, x, 0.1)
%% @end example
%%
%% @seealso{sym, vpa}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = vpasolve(e, x, x0)

  if (nargin < 3)
    x0 = sym(0);
  end
  if (nargin < 2)
    x = symvar(e, 1);
  end

  n = 32;  % default digits, FIXME.

  cmd = {
    '(e, x, x0, n) = _ins'
    'sympy.mpmath.mp.dps = n'
    'r = nsolve(e, x, x0)'
    'r = sympy.N(r, n)'  % gives mpf object
    'return r,' };

  r = python_cmd (cmd, sym(e), x, x0, n);

end


%!test
%! syms x
%! vpi = vpa(sym(pi), 64);
%! e = tan(x/4) == 1;
%! q = vpasolve(e, x, 3.0);
%! w = q - vpi ;
%! assert (double(w) < 1e-30)

%!test
%! syms x
%! vpi = vpa(sym(pi), 64);
%! e = tan(x/4) == 1;
%! q = vpasolve(e, x);
%! w = q - vpi;
%! assert (double(w) < 1e-30)
%! q = vpasolve(e);
%! w = q - vpi;
%! assert (double(w) < 1e-30)

