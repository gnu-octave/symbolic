%% Copyright (C) 2014-2016 Andrés Prieto
%% Copyright (C) 2015-2016, 2018-2019 Colin Macdonald
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
%% @defmethod  @@sym ilaplace (@var{G}, @var{s}, @var{t})
%% @defmethodx @@sym ilaplace (@var{G})
%% @defmethodx @@sym ilaplace (@var{G}, @var{t})
%% Inverse Laplace transform.
%%
%% The inverse Laplace transform of a function @var{G} of @var{s}
%% is a function @var{f} of @var{t} defined by the integral below.
%% @example
%% @group
%% syms g(s) t
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%% f(t) = rewrite(ilaplace(g), 'Integral')
%%   @result{} f(t) = (symfun)
%%           c + ∞⋅ⅈ
%%              ⌠
%%              ⎮          s⋅t
%%        -ⅈ⋅   ⎮    g(s)⋅ℯ    ds
%%              ⌡
%%           c - ∞⋅ⅈ
%%        ────────────────────────
%%                  2⋅π
%% @end group
%% @end example
%% (This expression is usually written simply as the integral divided by
%% @code{2⋅π⋅ⅈ}.)
%%
%% Example:
%% @example
%% @group
%% syms s t
%% F = 1/s^2;
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%% ilaplace(F, s, t)
%%   @result{} (sym) t⋅θ(t)
%% @end group
%% @end example
%%
%% To avoid @code{Heaviside}, try:
%% @example
%% @group
%% syms t positive
%% ilaplace(1/s^2, s, t)
%%   @result{} (sym) t
%% @end group
%% @end example
%%
%% By default the ouput is a function of @code{t} (or @code{x} if the
%% inverse transform happens to be with respect to @code{t}).  This can
%% be overriden by specifying @var{t}.  For example:
%% @example
%% @group
%% syms s
%% syms t x positive
%% ilaplace(1/s^2)
%%   @result{} (sym) t
%% ilaplace(1/t^2)
%%   @result{} (sym) x
%% ilaplace(1/s^2, x)
%%   @result{} (sym) x
%% @end group
%% @end example
%%
%% The independent variable of the input can be specified by @var{s};
%% if omitted it defaults a symbol named @code{s}, or @pxref{@@sym/symvar}
%% if no such symbol is found.
%%
%% @seealso{@@sym/laplace}
%% @end defmethod

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, integral transforms

function f = ilaplace(varargin)

  if (nargin > 3)
    print_usage ();
  end

  % FIXME: it only works for scalar functions

  F = sym(varargin{1});

  if (nargin == 3)
    s = sym(varargin{2});
  else
    %% frequency domain variable not specified
    % if exactly one symbol has char(s) == 's'...
    symbols = findsymbols (F);
    charsyms = cell (size (symbols));
    for i=1:numel(symbols)
      charsyms{i} = char (symbols{i});
    end
    I = find (strcmp (charsyms, 's'));
    assert (numel (I) <= 1, 'ilaplace: there is more than one "s" symbol: check symvar(F) and sympy(F)')
    if (~ isempty (I))
      s = symbols{I};  % ... we want that one
    else
      s = symvar (F, 1);
      if (isempty (s))
        s = sym('s');
      end
    end
  end

  if (nargin == 1)
    t = sym('t', 'positive');  % TODO: potentially confusing?
    % If the Laplace variable in the frequency domain is equal to "t",
    % "x" will be the physical variable (analogously to SMT)
    if (strcmp (char (s), char (t)))
      t = sym('x', 'positive');
    end
  elseif (nargin == 2)
    t = sym(varargin{2});
  elseif (nargin == 3)
    t = sym(varargin{3});
  end

  cmd = { 'F, s, t = _ins'
          'f = inverse_laplace_transform(F, s, t)'
          'if Version(spver) > Version("1.2"):'
          '    return f'
          '#'
          '# older sympy hacks'
          '#'
          'if not f.has(InverseLaplaceTransform):'
          '    return f,'
            'f=0; a_ = sp.Wild("a_"); b_ = sp.Wild("b_")'
            'Fr=F.rewrite(sp.exp)'
            'if type(Fr)==sp.Add:'
            '    terms=Fr.expand().args'
            'else:'
            '    terms=(Fr,)'
            'for term in terms:'
            '    #compute the Laplace transform for each term'
            '    r=sp.simplify(term).match(a_*sp.exp(b_))'
            '    if r!=None and sp.diff(term,s)!=0:'
            '        modulus=r[a_]'
            '        phase=r[b_]/s'
            '        # if a is constant and b/s is constant'
            '        if sp.diff(modulus,s)==0 and sp.diff(phase,s)==0:'
            '            f = f + modulus*sp.DiracDelta(t+phase)'
            '        else:'
            '            f = f + sp.Subs(sp.inverse_laplace_transform(term, s, t),sp.Heaviside(t),1).doit()'
            '    elif sp.diff(term,s)==0:'
            '        f = f + term*sp.DiracDelta(t)'
            '    else:'
            '        f = f + sp.Subs(sp.inverse_laplace_transform(term, s, t),sp.Heaviside(t),1).doit()'
            'return f,' };

  f = pycall_sympy__ (cmd, F, s, t);

end


%!error <Invalid> ilaplace (sym(1), 2, 3, 4)

%!test
%! % basic SMT compact: no heaviside
%! syms s
%! syms t positive
%! assert (isequal (ilaplace(1/s^2), t))
%! assert (isequal (ilaplace(s/(s^2+9)), cos(3*t)))
%! assert (isequal (ilaplace(6/s^4), t^3))

%!test
%! % more SMT compact
%! syms r
%! syms u positive
%! assert (isequal (ilaplace(1/r^2, u), u))
%! assert (isequal (ilaplace(1/r^2, r, u), u))

%!test
%! % if t specified and not positive, we expect heaviside
%! clear s t
%! syms s t
%! assert (isequal (ilaplace(1/s^2, s, t), t*heaviside(t)))
%! assert (isequal (ilaplace(s/(s^2+9), t), cos(3*t)*heaviside(t)))
%! assert (isequal (ilaplace(6/s^4, t), t^3*heaviside(t)))

%!test
%! % Heaviside test
%! syms s
%! t=sym('t', 'positive');
%! assert(logical( ilaplace(exp(-5*s)/s^2,t) == (t-5)*heaviside(t-5) ))

%!test
%! % Delta dirac test
%! syms s
%! t = sym('t');
%! assert (isequal (ilaplace (sym('2'), t), 2*dirac(t)))

%!test
%! % Delta dirac test 2
%! syms s c
%! t = sym('t', 'positive');
%! assert (isequal (ilaplace (5*exp(-3*s) + 2*exp(c*s) - 2*exp(-2*s)/s,t), ...
%!                  5*dirac(t-3) + 2*dirac(c+t) - 2*heaviside(t-2)))

%!error <more than one> ilaplace (sym('s', 'positive')*sym('s'))

%!test
%! % SMT compact, prefers s over symvar
%! syms s x
%! syms t positive
%! assert (isequal (ilaplace(x/s^4), x*t^3/6))
%! t = sym('t');
%! assert (isequal (ilaplace(x/s^4, t), x*t^3/6*heaviside(t)))

%!test
%! % pick s even it has assumptions
%! syms s real
%! syms x t
%! assert (isequal (ilaplace (x/s^2, t), x*t*heaviside(t)))
