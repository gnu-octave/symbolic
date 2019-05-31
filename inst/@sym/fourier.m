%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
%% Copyright (C) 2015-2016 Andrés Prieto
%% Copyright (C) 2015 Alexander Misel
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
%% @defmethod  @@sym fourier (@var{f}, @var{x}, @var{w})
%% @defmethodx @@sym fourier (@var{f})
%% @defmethodx @@sym fourier (@var{f}, @var{w})
%% Symbolic Fourier transform.
%%
%% The Fourier transform of a function @var{f} of @var{x}
%% is a function @var{FF} of @var{w} defined by the integral below.
%% @example
%% @group
%% syms f(x) w
%% FF(w) = rewrite(fourier(f), 'Integral')
%%   @result{} FF(w) = (symfun)
%%       ∞
%%       ⌠
%%       ⎮        -ⅈ⋅w⋅x
%%       ⎮  f(x)⋅ℯ       dx
%%       ⌡
%%       -∞
%% @end group
%% @end example
%%
%% Example:
%% @example
%% @group
%% syms x
%% f = exp(-abs(x));
%% fourier(f)
%%   @result{} (sym)
%%         2
%%       ──────
%%        2
%%       w  + 1
%% @end group
%% @end example
%%
%% Note @code{fourier} and @code{ifourier} implement the non-unitary,
%% angular frequency convention for L^2 functions and distributions.
%%
%% *WARNING*: As of SymPy 0.7.6 (June 2015), there are many problems
%% with (inverse) Fourier transforms of non-smooth functions, even very
%% simple ones.  Use at your own risk, or even better: help us fix SymPy.
%%
%% @seealso{@@sym/ifourier}
%% @end defmethod


function F = fourier(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  % If the physical variable of f is equal to "w",
  % "v" is the frequency domain variable (analogously to SMT)
  if (nargin == 1)
    f = sym(varargin{1});
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');
    end
    cmd = { 'f=_ins[0]; x=_ins[1]; k=sp.Symbol("w")'
            'if x==k:'
            '    k=sp.Symbol("v")'
            'F=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'fr=f.rewrite(sp.exp)'
            'if type(fr)==sp.Add:'
            '    terms=fr.expand().args'
            'else:'
            '    terms=(fr,)'
            'for term in terms:'
            '    #compute the Fourier transform '
            '    r=sp.simplify(term*sp.exp(-sp.I*x*k)).match(a_*sp.exp(b_))'
            '    # if a is constant and b/(I*x) is constant'
            '    modulus=r[a_]'
            '    phase=r[b_]/(sp.I*x)'
            '    if sp.diff(modulus,x)==0 and sp.diff(phase,x)==0:'
            '        F = F + modulus*2*sp.pi*sp.DiracDelta(-phase)'
            '    else:'
            '        Fterm=sp.integrate(sp.simplify(term*sp.exp(-sp.I*x*k)), (x, -sp.oo, sp.oo))'
            '        if Fterm.is_Piecewise:'
            '            F=F+sp.simplify(Fterm.args[0][0])'
            '        else:'
            '            F=F+sp.simplify(Fterm)'
            'return F,'};

    F = pycall_sympy__ (cmd, f, x);

  elseif (nargin == 2)
    f = sym(varargin{1});
    k = sym(varargin{2});
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');  % FIXME: should be dummy variable in case k was x
    end
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'fr=f.rewrite(sp.exp)'
            'if type(fr)==sp.Add:'
            '    terms=fr.expand().args'
            'else:'
            '    terms=(fr,)'
            'for term in terms:'
            '    #compute the Fourier transform '
            '    r=sp.simplify(term*sp.exp(-sp.I*x*k)).match(a_*sp.exp(b_))'
            '    # if a is constant and b/(I*x) is constant'
            '    modulus=r[a_]'
            '    phase=r[b_]/(sp.I*x)'
            '    if sp.diff(modulus,x)==0 and sp.diff(phase,x)==0:'
            '        F = F + modulus*2*sp.pi*sp.DiracDelta(-phase)'
            '    else:'
            '        Fterm=sp.integrate(sp.simplify(term*sp.exp(-sp.I*x*k)), (x, -sp.oo, sp.oo))'
            '        if Fterm.is_Piecewise:'
            '            F=F+sp.simplify(Fterm.args[0][0])'
            '        else:'
            '            F=F+sp.simplify(Fterm)'
            'return F,'};

    F = pycall_sympy__ (cmd, f, x, k);

  elseif (nargin == 3)
    f = sym(varargin{1});
    x = sym(varargin{2});
    k = sym(varargin{3});
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'fr=f.rewrite(sp.exp)'
            'if type(fr)==sp.Add:'
            '    terms=fr.expand().args'
            'else:'
            '    terms=(fr,)'
            'for term in terms:'
            '    #compute the Fourier transform '
            '    r=sp.simplify(term*sp.exp(-sp.I*x*k)).match(a_*sp.exp(b_))'
            '    # if a is constant and b/(I*x) is constant'
            '    modulus=r[a_]'
            '    phase=r[b_]/(sp.I*x)'
            '    if sp.diff(modulus,x)==0 and sp.diff(phase,x)==0:'
            '        F = F + modulus*2*sp.pi*sp.DiracDelta(-phase)'
            '    else:'
            '        Fterm=sp.integrate(sp.simplify(term*sp.exp(-sp.I*x*k)), (x, -sp.oo, sp.oo))'
            '        if Fterm.is_Piecewise:'
            '            F=F+sp.simplify(Fterm.args[0][0])'
            '        else:'
            '            F=F+sp.simplify(Fterm)'
            'return F,'};

    F = pycall_sympy__ (cmd, f, x, k);

  else
    print_usage ();

  end

end


%!test
%! % matlab SMT compatibiliy for arguments
%! syms r x u w v
%! Pi=sym('pi');
%! assert(logical( fourier(exp(-x^2)) == sqrt(Pi)/exp(w^2/4) ))
%! assert(logical( fourier(exp(-w^2)) == sqrt(Pi)/exp(v^2/4) ))
%! assert(logical( fourier(exp(-r^2),u) == sqrt(Pi)/exp(u^2/4) ))
%! assert(logical( fourier(exp(-r^2),r,u) == sqrt(Pi)/exp(u^2/4) ))

%!test
%! % basic tests
%! syms x w
%! assert(logical( fourier(exp(-abs(x))) == 2/(w^2 + 1) ))
%! assert(logical( fourier(x*exp(-abs(x))) == -(w*4*1i)/(w^4 + 2*w^2 + 1) ))

%!test
%! % Dirac delta tests
%! syms x w
%! Pi=sym('pi');
%! assert(logical( fourier(dirac(x-2)) == exp(-2*1i*w) ))
%! assert (logical( fourier(sym(2), x, w) == 4*Pi*dirac(w) ))

%!test
%! % advanced test
%! syms x w c d
%! Pi=sym('pi');
%! F=Pi*(dirac(w-c)+dirac(w+c))+2*Pi*1i*(dirac(w+3*d)-dirac(w-3*d))+2/(w^2+1);
%! assert(logical( fourier(cos(c*x)+2*sin(3*d*x)+exp(-abs(x))) == expand(F) ))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms x w f(x)
%! assert(logical( fourier(diff(f(x),x),x,w) == -1i*w*fourier(f(x),x,w) ))
