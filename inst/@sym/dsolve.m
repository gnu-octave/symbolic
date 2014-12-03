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
%% @deftypefn {Function File} {@var{g} =} dsolve (@var{de}, @var{y}, @var{ic})
%% Solve ODEs symbolically.
%%
%% Note @var{y} must be a symfun.
%% FIXME: not sure sympy is really so strict, currently in sym.
%% FIXME: deal with ICs?
%%
%% FIXME: SMT supports strings like 'Dy + y = 0': we are unlikely
%% to support this.
%%
%% @seealso{int}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function soln = dsolve(de, ic, varargin)

  if (nargin >= 2)
    error('FIXME: ICs not supported yet, issue #120')
  end

  % Usually we cast to sym in the _cmd call, but want to be
  % careful here b/c of symfuns
  %if ~ (isa(de, 'sym') && isa(ic, 'sym'))
  if (~isa(de, 'sym'))
    error('inputs must be sym or symfun')
  end

  % FIXME: might be nice to expose SymPy's "classify_ode"

  % FIXME: double-check its y(x) = soln...
  if (isscalar(de))
    cmd = { '(de,) = _ins'
            'g = sp.dsolve(de)'
            '#if isinstance(g, Equality):'
            '#    l = g.lhs'
            '#    r = g.rhs'
            'return g.rhs,' };

    soln = python_cmd (cmd, de);

  else
    error('TODO system case')
  end
end


%!test
%! syms y(x)
%! de = diff(y, 2) - 4*y == 0;
%! f = dsolve(de);
%! syms C1 C2
%! g1 = C1*exp(-2*x) + C2*exp(2*x);
%! g2 = C2*exp(-2*x) + C1*exp(2*x);
%! assert (isequal (f, g1) || isequal (f, g2))

%!xtest
%! % initial conditions
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3)
%! g = 3*cos(2*x) + C1*sin(2*x);
%! assert (isequal (f, g))
%! f = dsolve(de, y(0) == 3, y(2*pi/4) == 0);
%! g = 3*cos(2*x);
%! assert (isequal (f, g))

% FIXME: also test something with IC on diff(y)
