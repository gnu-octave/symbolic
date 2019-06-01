%% Copyright (C) 2014-2016, 2018-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{sol} =} dsolve (@var{ode})
%% @deftypemethodx @@sym {@var{sol} =} dsolve (@var{ode}, @var{IC})
%% @deftypemethodx @@sym {@var{sol} =} dsolve (@var{ode}, @var{IC1}, @var{IC2}, @dots{})
%% @deftypemethodx @@sym {[@var{sol}, @var{classify}] =} dsolve (@var{ode}, @var{IC})
%% Solve ordinary differential equations (ODEs) symbolically.
%%
%% Basic example:
%% @example
%% @group
%% syms y(x)
%% DE = diff(y, x) - 4*y == 0
%%   @result{} DE = (sym)
%%                 d
%%       -4⋅y(x) + ──(y(x)) = 0
%%                 dx
%% @end group
%%
%% @group
%% sol = dsolve (DE)
%%   @result{} sol = (sym)
%%                  4⋅x
%%       y(x) = C₁⋅ℯ
%% @end group
%% @end example
%%
%% You can specify initial conditions:
%% @example
%% @group
%% sol = dsolve (DE, y(0) == 1)
%%   @result{} sol = (sym)
%%               4⋅x
%%       y(x) = ℯ
%% @end group
%% @end example
%%
%% Note the result is an equation so if you need an expression
%% for the solution:
%% @example
%% @group
%% rhs (sol)
%%   @result{} (sym)
%%        4⋅x
%%       ℯ
%% @end group
%% @end example
%%
%% In some cases, SymPy can return a classification of the
%% differential equation:
%% @example
%% @group
%% DE = diff(y) == y^2
%%   @result{} DE = (sym)
%%       d           2
%%       ──(y(x)) = y (x)
%%       dx
%%
%% [sol, classify] = dsolve (DE, y(0) == 1)
%%   @result{} sol = (sym)
%%                -1
%%        y(x) = ─────
%%               x - 1
%%   @result{} classify = separable
%% @end group
%% @end example
%%
%% Many types of ODEs can be solved, including initial-value
%% problems and boundary-value problem:
%% @example
%% @group
%% DE = diff(y, 2) == -9*y
%%   @result{} DE = (sym)
%%          2
%%         d
%%        ───(y(x)) = -9⋅y(x)
%%          2
%%        dx
%%
%% dsolve (DE, y(0) == 1, diff(y)(0) == 12)
%%   @result{} (sym) y(x) = 4⋅sin(3⋅x) + cos(3⋅x)
%%
%% dsolve (DE, y(0) == 1, y(sym(pi)/2) == 2)
%%   @result{} (sym) y(x) = -2⋅sin(3⋅x) + cos(3⋅x)
%% @end group
%% @end example
%%
%% Some systems can be solved, including initial-value problems
%% involving linear systems of first order ODEs with constant
%% coefficients:
%% @example
%% @group
%% syms x(t) y(t)
%% ode_sys = [diff(x(t),t) == 2*y(t);  diff(y(t),t) == 2*x(t)]
%%   @result{} ode_sys = (sym 2×1 matrix)
%%       ⎡d                ⎤
%%       ⎢──(x(t)) = 2⋅y(t)⎥
%%       ⎢dt               ⎥
%%       ⎢                 ⎥
%%       ⎢d                ⎥
%%       ⎢──(y(t)) = 2⋅x(t)⎥
%%       ⎣dt               ⎦
%% @end group
%%
%% @group
%% soln = dsolve (ode_sys)
%%   @result{} soln = @{ ... @}
%% @end group
%%
%% @c doctest: +SKIP  # they might be re-ordered
%% @group
%% soln@{1@}
%%   @result{} ans =
%%       (sym)
%%                      -2⋅t         2⋅t
%%         x(t) = 2⋅C₁⋅ℯ     + 2⋅C₂⋅ℯ
%%
%% @c doctest: +SKIP  # they might be re-ordered
%% soln@{2@}
%%   @result{} ans =
%%       (sym)
%%                        -2⋅t         2⋅t
%%         y(t) = - 2⋅C₁⋅ℯ     + 2⋅C₂⋅ℯ
%% @end group
%% @end example
%%
%% @strong{WARNING}: As of SymPy 0.7.6 (May 2015), there are many problems
%% with systems, even very simple ones.  Use these at your own risk,
%% or even better: help us fix SymPy.
%%
%% Note: The Symbolic Math Toolbox supports strings like 'Dy + y = 0'; we
%% are unlikely to support this so you will need to assemble a symbolic
%% equation instead.
%%
%% FIXME: should we support a cell array list input for ICs/BCs?
%%
%% @seealso{@@sym/diff, @@sym/int, @@sym/solve}
%% @end deftypemethod

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
    classify = pycall_sympy__ ('return sp.ode.classify_ode(_ins[0])[0],', ode);
  elseif(~isscalar(ode) && nargout==2)
    warning('Classification of systems of ODEs is currently not supported')
    classify='';
  end

  cmd = { 'ode=_ins[0]; ics=_ins[1:]'
          '# convert our input to a dict'
          'ics2 = {}'
          'for s in ics:'
          '    ics2[s.lhs] = s.rhs'
          'sol = sp.dsolve(ode, ics=ics2)'
          'return sol,' };
  soln = pycall_sympy__ (cmd, ode, varargin{:});
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
%! g = 3*cos(2*x) + C1*sin(2*x);
%! try
%!   f = dsolve(de, y(0) == 3);
%!   waserr = false;
%! catch
%!   waserr = true;
%!   expectederr = regexp (lasterr (), 'Perhaps.*under-specified');
%! end
%! assert ((waserr && expectederr) || isequal (rhs(f), g))

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
%! % System of ODEs
%! syms x(t) y(t) C1 C2
%! ode1 = diff(x(t),t) == 2*y(t);
%! ode2 = diff(y(t),t) == 2*x(t);
%! soln = dsolve([ode1, ode2]);
%! g1 = [2*C1*exp(-2*t) + 2*C2*exp(2*t), -2*C1*exp(-2*t) + 2*C2*exp(2*t)];
%! g2 = [2*C1*exp(2*t) + 2*C2*exp(-2*t), 2*C1*exp(2*t) - 2*C2*exp(-2*t)];
%! assert (isequal ([rhs(soln{1}), rhs(soln{2})], g1) || ...
%!         isequal ([rhs(soln{1}), rhs(soln{2})], g2))

%!test
%! % System of ODEs (initial-value problem)
%! syms x(t) y(t)
%! ode_1=diff(x(t),t) == 2*y(t);
%! ode_2=diff(y(t),t) == 2*x(t);
%! sol_ivp=dsolve([ode_1,ode_2],x(0)==1,y(0)==0);
%! g_ivp=[exp(-2*t)/2+exp(2*t)/2,-exp(-2*t)/2+exp(2*t)/2];
%! assert (isequal ([rhs(sol_ivp{1}),rhs(sol_ivp{2})], g_ivp))

%!test
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 0, y(sym(pi)/4) == 1);
%! g = sin(2*x);
%! assert (isequal (rhs(f), g))

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

%!xtest
%! % forcing, Issue #183
%! syms x(t) y(t)
%! ode1 = diff(x) == x + sin(t) + 2;
%! ode2 = diff(y) == y - t - 3;
%! soln = dsolve([ode1 ode2], x(0) == 1, y(0) == 2);
%! X = rhs(soln{1});
%! Y = rhs(soln{2});
%! assert (isequal (diff(X) - (X + sin(t) + 2), 0))
%! assert (isequal (diff(Y) - (Y - t - 3), 0))

%!test
%! syms f(x) a b
%! de = diff(f, x) == 4*f;
%! s = dsolve(de, f(a) == b);
%! assert (isequal (subs(rhs(s), x, a), b))
