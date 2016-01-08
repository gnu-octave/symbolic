%% Copyright (C) 2014 Colin B. Macdonald
%% Copyright (C) 2014, 2015 Andrés Prieto, Alexander Misel, Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{f} =} ifourier (@var{FF}, @var{k}, @var{x})
%% @deftypefnx {Function File} {@var{f} =} ifourier (@var{FF})
%% @deftypefnx {Function File} {@var{f} =} ifourier (@var{FF}, @var{x})
%% Symbolic inverse Fourier transform.
%%
%% Example:
%% @example
%% @group
%% >> syms k
%% >> F = sqrt(sym(pi))*exp(-k^2/4);
%% >> ifourier(F)
%%    @result{} (sym)
%%         2
%%       -x
%%      ℯ
%% @end group
%% @group
%% >> F = 2*sym(pi)*dirac(k);
%% >> ifourier(F)
%%    @result{} ans = (sym) 1
%% @end group
%% @end example
%%
%% Note @code{fourier} and @code{ifourier} implement the non-unitary,
%% angular frequency convention for L^2 functions and distributions.
%%
%% *WARNING*: As of SymPy 0.7.6 (June 2015), there are many problems
%% with (inverse) Fourier transforms of non-smooth functions, even very
%% simple ones. Use at your own risk, or even better: help us fix SymPy.
%%
%% @seealso{fourier}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, integral transforms

function f = ifourier(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  % If the frequency variable determined to be "x", then
  % use "t" as the spatial domain variable (analogously to SMT)
  if (nargin == 1)
    F = sym(varargin{1});
    k = symvar(F, 1);  % note SMT does something different, prefers w
    if (isempty(k))
      k = sym('k');
    end
    cmd = { 'F=_ins[0]; k=_ins[1]; x=sp.Symbol("x")'
            'if x==k:'
            '    x=sp.Symbol("t")'
            'f=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'Fr=F.rewrite(sp.exp)'
            'if type(Fr)==sp.Add:'
            '    terms=Fr.expand().args'
            'else:'
            '    terms=(Fr,)'
            'for term in terms:'
            '    #compute the Fourier transform '
            '    r=sp.simplify(term*sp.exp(sp.I*x*k)).match(a_*sp.exp(b_))'
            '    # if a is constant and b/(I*k) is constant'
            '    rlist=list(r.values())'
            '    modulus=rlist[0]'
            '    phase=rlist[1]/(sp.I*k)'
            '    if sp.diff(modulus,k)==0 and sp.diff(phase,k)==0:'
            '        f = f + modulus*2*sp.pi*sp.DiracDelta(phase)'
            '    else:'
            '        fterm=sp.integrate(sp.simplify(term*sp.exp(sp.I*x*k)), (k, -sp.oo, sp.oo))'
            '        if fterm.is_Piecewise:'
            '            f=f+sp.simplify(fterm.args[0][0])'
            '        else:'
            '            f=f+sp.simplify(fterm)'
            'return f/(2*sp.pi),'};

    f = python_cmd(cmd, F, k);

  elseif (nargin == 2)
    F = sym(varargin{1});
    x = sym(varargin{2});
    k = symvar(F, 1);  % note SMT does something different, prefers w
    if (isempty(k))
      k = sym('k');
    end
    cmd = { 'F=_ins[0]; k=_ins[1]; x=_ins[2]'
            'f=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'Fr=F.rewrite(sp.exp)'
            'if type(Fr)==sp.Add:'
            '    terms=Fr.expand().args'
            'else:'
            '    terms=(Fr,)'
            'for term in terms:'
            '    #compute the Fourier transform '
            '    r=sp.simplify(term*sp.exp(sp.I*x*k)).match(a_*sp.exp(b_))'
            '    # if a is constant and b/(I*k) is constant'
            '    rlist=list(r.values())'
            '    modulus=rlist[0]'
            '    phase=rlist[1]/(sp.I*k)'
            '    if sp.diff(modulus,k)==0 and sp.diff(phase,k)==0:'
            '        f = f + modulus*2*sp.pi*sp.DiracDelta(phase)'
            '    else:'
            '        fterm=sp.integrate(sp.simplify(term*sp.exp(sp.I*x*k)), (k, -sp.oo, sp.oo))'
            '        if fterm.is_Piecewise:'
            '            f=f+sp.simplify(fterm.args[0][0])'
            '        else:'
            '            f=f+sp.simplify(fterm)'
            'return f/(2*sp.pi),'};

    f = python_cmd(cmd, F, k, x);

  elseif (nargin == 3)
    F = sym(varargin{1});
    k = sym(varargin{2});
    x = sym(varargin{3});
    cmd = { 'F=_ins[0]; k=_ins[1]; x=_ins[2]'
            'f=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'Fr=F.rewrite(sp.exp)'
            'if type(Fr)==sp.Add:'
            '    terms=Fr.expand().args'
            'else:'
            '    terms=(Fr,)'
            'for term in terms:'
            '    #compute the Fourier transform '
            '    r=sp.simplify(term*sp.exp(sp.I*x*k)).match(a_*sp.exp(b_))'
            '    # if a is constant and b/(I*k) is constant'
            '    rlist=list(r.values())'
            '    modulus=rlist[0]'
            '    phase=rlist[1]/(sp.I*k)'
            '    if sp.diff(modulus,k)==0 and sp.diff(phase,k)==0:'
            '        f = f + modulus*2*sp.pi*sp.DiracDelta(phase)'
            '    else:'
            '        fterm=sp.integrate(sp.simplify(term*sp.exp(sp.I*x*k)), (k, -sp.oo, sp.oo))'
            '        if fterm.is_Piecewise:'
            '            f=f+sp.simplify(fterm.args[0][0])'
            '        else:'
            '            f=f+sp.simplify(fterm)'
            'return f/(2*sp.pi),'};

    f = python_cmd(cmd, F, k, x);

  else
    print_usage ();

  end

end


%!test
%! % matlab SMT compat
%! syms t r u x w
%! Pi=sym('pi');
%! assert(logical( ifourier(exp(-abs(w))) == 1/(Pi*(x^2 + 1)) ))
%! assert(logical( ifourier(exp(-abs(x))) == 1/(Pi*(t^2 + 1)) ))
%! assert(logical( ifourier(exp(-abs(r)),u) == 1/(Pi*(u^2 + 1)) ))
%! assert(logical( ifourier(exp(-abs(r)),r,u) == 1/(Pi*(u^2 + 1)) ))

%!test
%! % basic
%! syms x w
%! Pi=sym('pi');
%! assert(logical( ifourier(exp(-w^2/4)) == 1/(sqrt(Pi)*exp(x^2)) ))
%! assert(logical( ifourier(sqrt(Pi)/exp(w^2/4)) == exp(-x^2) ))

%!test
%! % Dirac delta tests
%! syms x w
%! Pi=sym('pi');
%! assert(logical( ifourier(dirac(w-2)) == exp(2*1i*x)/(2*Pi) ))
%! assert (logical( ifourier(sym(2), w, x) == 2*dirac(x) ))

%!test
%! % advanced test
%! syms x w c d
%! Pi=sym('pi');
%! f=(Pi*(dirac(x-c)+dirac(x+c))+2*Pi*1i*(-dirac(x+3*d)+dirac(x-3*d))+2/(x^2+1))/(2*Pi);
%! assert(logical( simplify(ifourier(cos(c*w)+2*sin(3*d*w)+exp(-abs(w)))-f) == 0 ))

%!xtest
%! % Inverse Fourier transform cannot recover non-smooth functions
%! % SymPy cannot evaluate correctly??
%! syms x w
%! assert(logical( ifourier(2/(w^2 + 1)) == exp(-abs(x)) ))
%! assert(logical( ifourier(2/(w^2 + 1)) == heaviside(x)/exp(x) + heaviside(-x)*exp(x) ))
%! assert(logical( ifourier(-(w*4)/(w^4 + 2*w^2 + 1) )== -x*exp(-abs(x))*1i ))
%! assert(logical( ifourier(-(w*4)/(w^4 + 2*w^2 + 1) )== -x*(heaviside(x)/exp(x) + heaviside(-x)*exp(x))*1i ))
