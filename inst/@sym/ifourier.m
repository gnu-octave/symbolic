%% Copyright (C) 2014-2016, 2018-2019 Colin B. Macdonald
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
%% @defmethod  @@sym ifourier (@var{G}, @var{w}, @var{x})
%% @defmethodx @@sym ifourier (@var{G})
%% @defmethodx @@sym ifourier (@var{G}, @var{x})
%% Symbolic inverse Fourier transform.
%%
%% The inverse Fourier transform of a function @var{G} of @var{w}
%% is a function @var{f} of @var{x} defined by the integral below.
%% @example
%% @group
%% syms G(w) x
%% f(x) = rewrite(ifourier(G), 'Integral')
%%   @result{} f(x) = (symfun)
%%       ∞
%%       ⌠
%%       ⎮        ⅈ⋅w⋅x
%%       ⎮  G(w)⋅ℯ      dw
%%       ⌡
%%       -∞
%%       ─────────────────
%%              2⋅π
%% @end group
%% @end example
%%
%% Example:
%% @example
%% @group
%% syms k
%% F = sqrt(sym(pi))*exp(-k^2/4);
%% ifourier(F)
%%   @result{} (sym)
%%          2
%%        -x
%%       ℯ
%% @end group
%% @group
%% F = 2*sym(pi)*dirac(k);
%% ifourier(F)
%%   @result{} ans = (sym) 1
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
%% @seealso{@@sym/fourier}
%% @end defmethod


function f = ifourier(varargin)

  if (nargin > 3)
    print_usage ();
  end

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  F = sym(varargin{1});

  if (nargin == 3)
    k = sym(varargin{2});
  else
    %% frequency domain variable not specifed
    % if exactly one symbol has char(k) == 'k'...
    symbols = findsymbols (F);
    charsyms = cell (size (symbols));
    for i=1:numel(symbols)
      charsyms{i} = char (symbols{i});
    end
    I = find (strcmp (charsyms, 'k'));
    assert (numel (I) <= 1, 'ifourier: there is more than one "k" symbol: check symvar(F) and sympy(F)')
    if (~ isempty (I))
      k = symbols{I};  % ... we want that one
    else
      k = symvar(F, 1);  % else we use symvar choice
      if (isempty(k))
        k = sym('k');
      end
    end
  end

  if (nargin == 1)
    x = sym('x');
    %% If the frequency variable k turned out to be "x", then
    % use "t" as the spatial domain variable (analogously to SMT)
    if (strcmp (char (k), char (x)))
      x = sym('t');
    end
  elseif (nargin == 2)
    x = sym(varargin{2});
  elseif (nargin == 3)
    x = sym(varargin{3});
  end

  cmd = { 'F, k, x = _ins'
          '#f = inverse_fourier_transform(F, k, x)'
          '#return f.subs(x, x/(2*S.Pi)) / (2*S.Pi)'
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
            '    modulus=r[a_]'
            '    phase=r[b_]/(sp.I*k)'
            '    if sp.diff(modulus,k)==0 and sp.diff(phase,k)==0:'
            '        f = f + modulus*2*sp.pi*sp.DiracDelta(phase)'
            '    else:'
            '        fterm=sp.integrate(sp.simplify(term*sp.exp(sp.I*x*k)), (k, -sp.oo, sp.oo))'
            '        if fterm.is_Piecewise:'
            '            f=f+sp.simplify(fterm.args[0][0])'
            '        else:'
            '            f=f+sp.simplify(fterm)'
            'return f/(2*sp.pi),'};

  f = pycall_sympy__ (cmd, F, k, x);

end


%!error <Invalid> ifourier (sym(1), 2, 3, 4)

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

%!error <more than one> ifourier (sym('k', 'positive')*sym('k'))

%!test
%! % SMT compact, prefers k over symvar
%! syms k x y
%! assert (isequal (ifourier(y*exp(-k^2/4)), y/sqrt(sym(pi))*exp(-x^2)))
