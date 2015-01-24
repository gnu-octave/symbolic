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
%% @deftypefn  {Function File} {@var{sol} =} dsolve (@var{ode})
%% @deftypefnx {Function File} {@var{sol} =} dsolve (@var{ode}, @var{ics})
%% Solve ordinary differentual equations (ODEs) symbolically.
%%
%% Many types of ODEs can be solved, including initial-value
%% problems and boundary-value problem.  Some systems can be
%% solved, including initial-value problems involving linear systems
%% of first order ODEs with constant coefficients.
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

  % FIXME: might be nice to expose SymPy's "sp.ode.classify_sysode" and
  %        "sp.ode.classify_ode" with their own commands
  if (isscalar(ode) && nargout==2)
    classify = python_cmd ('return sp.ode.classify_ode(_ins[0])[0],', ode);
  elseif(~isscalar(ode) && nargout==2)
    disp('Classification of systems of ODEs is currently not supported')
    classify='';
  end

  % FIXME: it is not currently supported a list of boundary/initial conditions
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
          '# Auxiliary function'
          'def eqs2matrix(eqs, syms):'
          '    s = sp.Matrix([si.lhs - si.rhs if isinstance(si, sp.Equality) else si for si in eqs])'
          '    j = s.jacobian(syms)'
          '    return (j, -sp.simplify(s - j*sp.Matrix(syms)))'
          '# Identify dependent and independent variables'
          'dependent_var = list(sp.ordered(reduce(set.union, [ode_i.atoms(sp.function.AppliedUndef) for ode_i in ode], set())))'
          'independent_var = list(sp.ordered(reduce(set.union, [ode_i.free_symbols for ode_i in ode], set())))'
          'if (sp.symbols("s")==independent_var):'
          '    laplace_var = sp.symbols("x")'
          'else:'
          '    laplace_var = sp.symbols("s")'
          '# matrix formulation of the linear system'
          'diff_dependent_var=list()'
          'for fun in dependent_var:'
          '    diff_dependent_var.append(sp.diff(fun))'
          '# ODE system: K*dX+M*X-B==0'
          'K,rhs=eqs2matrix(ode, diff_dependent_var)'
          'M,rhs=eqs2matrix(ode, dependent_var)'
          'X=sp.Matrix(dependent_var)'
          'dX=sp.Matrix(diff_dependent_var)'
          'B=rhs+K*dX'
          '# Transformed rhs B: Z=laplace(B)'
          'Z=sp.laplace_transform(B, independent_var[0], laplace_var)'
          'D=sp.Matrix(list(it[0] for it in list(Z)))'
          '# First term of the homogeneous ODE'
          'Y=sp.Matrix(sp.symbols("Y1:"+str(len(ode)+1)))'
          '# Homogeneous general solution Y=laplace(X), then (K*s+M)Y==B-K*C'
          'sol=sp.zeros(len(ode),1)'
          'for i in range(0,len(ode)):'
          '    C=sp.zeros(len(ode),1);C[i]=1'
          '    sol_h=sp.solve((K*laplace_var+M)*Y+K*C,Y)'
          '    Yh=sp.zeros(len(ode),1)'
          '    for el in sol_h.items():'
          '        for j in range(0,len(ode)): '
          '            if Y[j]==el[0]:'
          '                Yh[j]=el[1]'
          '    sol=sol+sp.symbols("C"+str(i+1))*sp.inverse_laplace_transform(Yh, laplace_var, independent_var[0])'
          '# Particular solution'
          'sol_p=sp.solve((K*laplace_var+M)*Y-D,Y)'
          'Yp=sp.zeros(len(ode),1)'
          'for el in sol_p.items():'
          '    for j in range(0,len(ode)): '
          '        if Y[j]==el[0]:'
          '            Yp[j]=el[1]'
          'sol=sol+sp.inverse_laplace_transform(Yp, laplace_var, independent_var[0])'
          '# Constant simplification'
          'sol=sp.Subs(sol,sp.Heaviside(independent_var[0]),1).doit()'
          'sol=sp.ode.constantsimp(sp.simplify(sol), set(sp.symbols("C1:"+str(len(ode)+1))))'
          'sol=list(sp.Eq(dependent_var[i],sol[i]) for i in range(0,len(ode)))'
          '# Application of the initial conditions'
          'init_var=list(sp.ordered(reduce(set.union, [ics_i.atoms(sp.function.AppliedUndef) for ics_i in ics], set())))'
          'init_values=sp.solve(ics,init_var).items()'
          '# Impose boundary conditions'
          'ic_eqs=[]'
          'for solu in sol:'
          '    ic_eqs.append(solu)'
          '    for val in init_values:'
          '        ic_eqs[-1]=ic_eqs[-1].subs(independent_var[0],val[0].args[0]).subs(val[0],val[1])'
          'sol_C=sp.solve(ic_eqs)'
          'if(type(sol_C)==list):'
          '    sol_C=sol_C[0]'
          'sol_final=[]'
          'for y in sol:'
          '    sol_final.append(y.subs(sol_C))'
          'return sol_final,'};

    soln = python_cmd (cmd, ode, varargin{:});

  elseif(isscalar(ode) && nargin==1)

    soln = python_cmd ('return sp.dsolve(*_ins),', ode);

  elseif(~isscalar(ode) && nargin==1)

  cmd = { 'ode=_ins[0]'
          '# Auxiliary function'
          'def eqs2matrix(eqs, syms):'
          '    s = sp.Matrix([si.lhs - si.rhs if isinstance(si, sp.Equality) else si for si in eqs])'
          '    j = s.jacobian(syms)'
          '    return (j, -sp.simplify(s - j*sp.Matrix(syms)))'
          '# Identify dependent and independent variables'
          'dependent_var = list(sp.ordered(reduce(set.union, [ode_i.atoms(sp.function.AppliedUndef) for ode_i in ode], set())))'
          'independent_var = list(sp.ordered(reduce(set.union, [ode_i.free_symbols for ode_i in ode], set())))'
          'if (sp.symbols("s")==independent_var):'
          '    laplace_var = sp.symbols("x")'
          'else:'
          '    laplace_var = sp.symbols("s")'
          '# matrix formulation of the linear system'
          'diff_dependent_var=list()'
          'for fun in dependent_var:'
          '    diff_dependent_var.append(sp.diff(fun))'
          '# ODE system: K*dX+M*X-B==0'
          'K,rhs=eqs2matrix(ode, diff_dependent_var)'
          'M,rhs=eqs2matrix(ode, dependent_var)'
          'X=sp.Matrix(dependent_var)'
          'dX=sp.Matrix(diff_dependent_var)'
          'B=rhs+K*dX'
          '# Transformed rhs B: Z=laplace(B)'
          'Z=sp.laplace_transform(B, independent_var[0], laplace_var)'
          'D=sp.Matrix(list(it[0] for it in list(Z)))'
          '# First term of the homogeneous ODE'
          'Y=sp.Matrix(sp.symbols("Y1:"+str(len(ode)+1)))'
          '# Homogeneous general solution Y=laplace(X), then (K*s+M)Y==B-K*C'
          'sol=sp.zeros(len(ode),1)'
          'for i in range(0,len(ode)):'
          '    C=sp.zeros(len(ode),1);C[i]=1'
          '    sol_h=sp.solve((K*laplace_var+M)*Y+K*C,Y)'
          '    Yh=sp.zeros(len(ode),1)'
          '    for el in sol_h.items():'
          '        for j in range(0,len(ode)): '
          '            if Y[j]==el[0]:'
          '                Yh[j]=el[1]'
          '    sol=sol+sp.symbols("C"+str(i+1))*sp.inverse_laplace_transform(Yh, laplace_var, independent_var[0])'
          '# Particular solution'
          'sol_p=sp.solve((K*laplace_var+M)*Y-D,Y)'
          'Yp=sp.zeros(len(ode),1)'
          'for el in sol_p.items():'
          '    for j in range(0,len(ode)): '
          '        if Y[j]==el[0]:'
          '            Yp[j]=el[1]'
          'sol=sol+sp.inverse_laplace_transform(Yp, laplace_var, independent_var[0])'
          '# Constant simplification'
          'sol=sp.Subs(sol,sp.Heaviside(independent_var[0]),1).doit()'
          'sol=sp.ode.constantsimp(sp.simplify(sol), set(sp.symbols("C1:"+str(len(ode)+1))))'
          'sol=list(sp.Eq(dependent_var[i],sol[i]) for i in range(0,len(ode)))'
          'return sol,'};

    soln = python_cmd (cmd, ode);

  end
end


%!test
%! syms y(x)
%! de = diff(y, 2) - 4*y == 0;
%! f = dsolve(de);
%! syms C1 C2
%! g1 = C1*exp(-2*x) + C2*exp(2*x);
%! g2 = C2*exp(-2*x) + C1*exp(2*x);
%! assert (isequal (rhs(f), g1) || isequal (rhs(f), g2))

%!test
%! % Not enough initial conditions
%! syms y(x) C1
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3);
%! g = 3*cos(2*x) + C1*sin(2*x);
%! assert (isequal (rhs(f), g))

%!test
%! % Solution in implicit form
%! syms y(x) C1
%! sol=dsolve((2*x*y(x)-exp(-2*y(x)))*diff(y(x),x)+y(x)==0);
%! eq=x*exp(2*y(x))-log(y(x))==C1;
%! assert (isequal (rhs(sol), rhs(eq)) && isequal (lhs(sol), lhs(eq)) )

%!test
%! % Compute solution and classification
%! syms y(x) C1
%! [sol,classy]=dsolve((2*x*y(x)-exp(-2*y(x)))*diff(y(x),x)+y(x)==0);
%! eq=x*exp(2*y(x))-log(y(x))==C1;
%! assert (isequal (rhs(sol), rhs(eq)) && isequal (lhs(sol), lhs(eq)))
%! assert (strcmp (classy, '1st_exact'))

%!test
%! % initial conditions (first order ode)
%! syms y(x)
%! de = diff(y, x) + 4*y == 0;
%! f = dsolve(de, y(0) == 3);
%! g = 3*exp(-4*x);
%! assert (isequal (rhs(f), g))

%!test
%! % initial conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, subs(diff(y,x),x,0)==0);
%! g = 3*cos(2*x);
%! assert (isequal (rhs(f), g))

%!test
%! % Dirichlet boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 2, y(1) == 0);
%! g = -2*sin(2*x)/tan(sym('2'))+2*cos(2*x);
%! assert (isequal (rhs(f), g))

%!test
%! % Neumann boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, subs(diff(y,x),x,0)==1, subs(diff(y,x),x,1)==0);
%! g = sin(2*x)/2+cos(2*x)/(2*tan(sym('2')));
%! assert (isequal (rhs(f), g))

%!test
%! % Dirichlet-Neumann boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, subs(diff(y,x),x,1)==0);
%! g = 3*sin(2*x)*tan(sym('2'))+3*cos(2*x);
%! assert (isequal (rhs(f), g))

%!test
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 0, y(sym(pi)/4) == 1);
%! g = sin(2*x);
%! assert (isequal (rhs(f), g))

%!test
%! % Test with symbolic constants on initial conditions
%! syms a b t x(t);
%! e1 = diff(x,t) == x + 2*t + 2;
%! S=dsolve(e1,x(a)==b);
%! X=rhs(S{1});
%! assert (isequal(simplify(diff(X) - (X + 2*t + 2)),0))
%! assert (isequal(simplify(subs(X,t,a)),b))

%!test
%! % Nonlinear example
%! syms y(x) C1
%! e = diff(y, x) == y^2;
%! g = -1 / (C1 + x);
%! soln = dsolve(e);
%! assert (isequal (rhs(soln), g))

%!test
%! % Nonlinear example with initial condition
%! syms y(x)
%! e = diff(y, x) == y^2;
%! g = -1 / (x - 1);
%! soln = dsolve(e, y(0) == 1);
%! assert (isequal (rhs(soln), g))

%!test
%! % System of ODEs (general solution, polynomial rhs)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%!  syms t x(t) y(t);
%!  e1 = diff(x,t) == x+4*y - t + 2;
%!  e2 = diff(y,t) == x - 2*y + 5*t;
%!  S = dsolve([e1, e2]);
%!  X = rhs(S{1});  Y = rhs(S{2});  
%!  assert (isequal(simplify(diff(X,t) - (X+4*Y - t + 2)),0) && isequal(simplify(diff(Y,t) - (X - 2*Y + 5*t)),0))
%! end

%!test
%! % System of ODEs (general solution, trigonometric + constant rhs)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%!  syms t x(t) y(t);
%!  e1 = diff(x,t) == x + 2*sin(t) + 2;
%!  e2 = diff(y,t) == y;
%!  S = dsolve([e1, e2]);
%!  X = rhs(S{1});  Y = rhs(S{2});  
%!  assert (isequal(simplify(diff(X,t) - (X + 2*sin(t) + 2)),0) && isequal(simplify(diff(Y,t) - Y),0))
%! end

%!test
%! % System of ODEs (general solution)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%!  syms t x(t) y(t);
%!  e1 = diff(x,t) == 3*t;
%!  e2 = diff(y,t) == y;
%!  S = dsolve([e1, e2]);
%!  X = rhs(S{1});  Y = rhs(S{2});  
%!  assert (isequal(simplify(diff(X,t) - 3*t),0) && isequal(simplify(diff(Y,t) - Y),0))
%! end

%!test
%! % System of ODEs (general solution)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%! syms t x(t) y(t)
%!  ode_1=diff(x(t),t) == 2*y(t);
%!  ode_2=diff(y(t),t) == 2*x(t)-3*t;
%!  sol_sodes=dsolve([ode_1,ode_2]);
%!  X=rhs(sol_sodes{1});
%!  Y=rhs(sol_sodes{2});
%!  assert (isequal(diff(X,t) -2*Y,0) && isequal(diff(Y,t)-2*X+3*t,0))
%! end

%!test
%! % System of ODEs (explicit initial conditions)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%!  syms t x(t) y(t)
%!  ode_1=diff(x(t),t) == 2*y(t);
%!  ode_2=diff(y(t),t) == 2*x(t)-3*t;
%!  sol_ivp=dsolve([ode_1,ode_2],x(0)==1,y(0)==0);
%!  X=rhs(sol_ivp{1});
%!  Y=rhs(sol_ivp{2});
%!  assert (isequal(diff(X,t) -2*Y,0) && isequal(diff(Y,t)-2*X+3*t,0))
%!  assert (isequal(subs(X,t,0),1) && isequal(subs(Y,t,0),0))
%! end

%!test
%! % System of ODEs (implicit initial conditions)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%!  syms t x(t) y(t)
%!  ode_1=diff(x(t),t) == 2*y(t);
%!  ode_2=diff(y(t),t) == 2*x(t)-3*t;
%!  sol_ivp=dsolve([ode_1,ode_2],x(0)+y(0)==1,y(0)-x(0)==-1);
%!  X=rhs(sol_ivp{1});
%!  Y=rhs(sol_ivp{2});
%!  assert (isequal(diff(X,t) -2*Y,0) && isequal(diff(Y,t)-2*X+3*t,0))
%!  assert (isequal(subs(X,t,0),1) && isequal(subs(Y,t,0),0))
%! end

%!test
%! % System of ODEs (implicit initial conditions with symbolic constants)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!  disp('skipping: Solution of ODE systems needs sympy >= 0.7.6')
%! else
%!  syms a b t x(t) y(t)
%!  ode_1=diff(x(t),t) == 2*y(t);
%!  ode_2=diff(y(t),t) == 2*x(t)-3*t;
%!  sol_ivp=dsolve([ode_1,ode_2],x(a)+y(a)==b,y(a)-x(a)==-b);
%!  X=rhs(sol_ivp{1});
%!  Y=rhs(sol_ivp{2});
%!  assert (isequal(diff(X,t) -2*Y,0) && isequal(diff(Y,t)-2*X+3*t,0))
%!  assert (isequal(simplify(subs(X,t,a)),b) && isequal(simplify(subs(Y,t,a)),0))
%! end
