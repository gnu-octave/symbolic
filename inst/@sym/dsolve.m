%% Copyright (C) 2014 Colin B. Macdonald, Andrés Prieto
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
%% @deftypefn {Function File} {@var{sol} =} dsolve (@var{ode}, @var{ics})
%% Solve ODEs symbolically.
%% Solve initial-value / boundary-value differential problems symbolically.
%% Solve initial-value problems symbolically involving linear systems 
%%  of first order ODEs with constant coefficients
%%
%% FIXME: SMT supports strings like 'Dy + y = 0': we are unlikely
%% to support this.
%%
%% @seealso{int}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic


function [soln,classify] = dsolve(ode,varargin)

  % Usually we cast to sym in the _cmd call, but want to be
  % careful here b/c of symfuns
  if (any(~isa(ode, 'sym')))
    error('Inputs must be sym or symfun')
  end

  % FIXME: might be nice to expose SymPy's "sp.ode.classify_sysode"
  if (isscalar(ode) && nargout==2)
    classify = python_cmd ('return sp.ode.classify_ode(_ins[0])[0],', ode);
  elseif(~isscalar(ode) && nargout==2)
    disp('Classification of systems of ODEs is currently not supported')
    classify='';
  end

  % FIXME: the initial/boundary conditions admit parameters
  %        but only on their values (not at the evaluation point) 

  if (isscalar(ode) && nargin>=2)
  cmd = { 'ode=_ins[0]; ics=_ins[1:]'
          'sol=sp.dsolve(ode)'
          'x=list(ode.free_symbols)[0]'
          'ic_eqs=[]'
          'for ic in ics:'
          '    funcarg=ic.lhs'
          '    if isinstance(funcarg, sp.Subs):'
          '        x0=funcarg.point[0]'
          '        dorder=sp.ode_order(funcarg.expr, x)'
          '        dsol_eq=sp.Eq(sp.diff(sol.lhs,x,dorder),sp.diff(sol.rhs,x,dorder))'
          '        dy_at_x0=funcarg.expr.subs(x,x0)'
          '        ic_eqs.append(dsol_eq.subs(x,x0).subs(dy_at_x0,ic.rhs))'
          '    elif isinstance(funcarg, sp.function.AppliedUndef):'
          '        x0=funcarg.args[0]'
          '        ic_eqs.append(sol.subs(x,x0).subs(funcarg,ic.rhs))'
          'sol_C=sp.solve(ic_eqs)'
          'if type(sol_C)==dict:'
          '    sol_final=sol.subs(sol_C)'
          'elif type(sol_C)==list:'
          '    sol_final=[]'
          '    for c in sol_C:'
          '        sol_final.append(sol.subs(c))'
          'return sol_final,'};

    soln = python_cmd (cmd, ode, varargin{:});

  % FIXME: only solve initial-value problems involving linear systems 
  %        of first order ODEs with constant coefficients (a unique
  %        solution is expected)
  elseif(~isscalar(ode) && nargin>=2)

  cmd = { 'ode=_ins[0]; ics=_ins[1:]'
          'sol=sp.dsolve(ode)'
          'x=list(ode[0].free_symbols)[0]'
          'ic_eqs=[]'
          'for solu in sol:'
          '    ic_eqs.append(solu)'
          '    for ic in ics:'
          '        funcarg=ic.lhs'
          '        if isinstance(funcarg, sp.function.AppliedUndef):'
          '            x0=funcarg.args[0]'
          '            ic_eqs[-1]=ic_eqs[-1].subs(x,x0).subs(funcarg,ic.rhs)'
          'sol_C=sp.solve(ic_eqs)'
          'sol_final=[]'
          'for y in sol:'
          '    sol_final.append(y.subs(sol_C))'
          'return sol_final,'};

    soln = python_cmd (cmd, ode, varargin{:});

  elseif(nargin==1)

    soln = python_cmd ('return sp.dsolve(*_ins),', ode);

  end
end


%!test
%! syms x y(x)
%! de = diff(y, 2) - 4*y == 0;
%! f = dsolve(de);
%! syms C1 C2
%! g1 = C1*exp(-2*x) + C2*exp(2*x);
%! g2 = C2*exp(-2*x) + C1*exp(2*x);
%! assert (isequal (rhs(f), rhs(g1)) || isequal (rhs(f), rhs(g2)))
 
%!test
%! % Solution in implicit form
%! syms x y(x)
%! sol=dsolve((2*x*y(x)-exp(-2*y(x)))*diff(y(x),x)+y(x)==0)
%! eq=x*exp(2*y(x))-log(y(x))==C1
%! assert (isequal (sol, eq))

%!test
%! % initial conditions (first order ode)
%! syms x y(x)
%! de = diff(y, x, 1) + 4*y == 0;
%! f = dsolve(de, y(0) == 3)
%! g = 3*exp(-4*x);
%! assert (isequal (rhs(f), rhs(g)))

%!test
%! % initial conditions (second order ode)
%! syms x y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, subs(diff(y,x,1),x,0)==0)
%! g = 3*cos(2*x);
%! assert (isequal (rhs(f), rhs(g)))

%!test
%! % Dirichlet boundary conditions (second order ode)
%! syms x y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, y(1) == 0)
%! g = -3*sin(2*x)/tan(2)+3*cos(2*x);
%! assert (isequal (rhs(f), rhs(g)))

%!test
%! % Neumann boundary conditions (second order ode)
%! syms x y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, subs(diff(y,x,1),x,0)==1, subs(diff(y,x,1),x,1)==0)
%! g = sin(2*x)/2+cos(2*x)/(2*tan(2));
%! assert (isequal (rhs(f), rhs(g)))

%!test
%! % Dirichlet-Neumann boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, subs(diff(y,x,1),x,1)==0)
%! g = 3*sin(2*x)*tan(2)+3*cos(2*x);
%! assert (isequal (rhs(f), rhs(g)))

%!test
%! % System of ODEs (initial-value problem)
%! syms t x(t) y(t) C1 C2
%! ode_1=diff(x(t),t) == 2*y(t);
%! ode_2=diff(y(t),t) == 2*x(t)-3*t;
%! sol_sodes=dsolve([ode_1,ode_2])
%! g=[2*C1*exp(-2*t)+2*C2*exp(2*t),-2*C1*exp(-2*t)+2*C2*exp(2*t)]
%! sol_ivp=dsolve([ode_1,ode_2],x(0)==1,y(0)==0)
%! g_ivp=[exp(-2*t)/2+exp(2*t)/2,-exp(-2*t)/2+exp(2*t)/2]
%! assert (isequal ([rhs(sol_sodes{1}),rhs(sol_sodes{2})], g))
%! assert (isequal ([rhs(sol_ivp{1}),rhs(sol_ivp{2})], g_ivp))

%!xtest
%! % initial conditions: it fails since 2*pi/4 are replaced by a rational number
%! syms x y(x)
%! f = dsolve(de, y(0) == 3, y(2*pi/4) == 0);
%! g = 3*cos(2*x);
%! assert (isequal (f, g))


