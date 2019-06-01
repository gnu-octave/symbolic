%% Copyright (C) 2014-2016 Andrés Prieto
%% Copyright (C) 2015-2016, 2019 Colin Macdonald
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
%% @defmethod  @@sym laplace (@var{f}, @var{t}, @var{s})
%% @defmethodx @@sym laplace (@var{f})
%% @defmethodx @@sym laplace (@var{f}, @var{s})
%% Laplace transform.
%%
%% The Laplace transform of a function @var{f} of @var{t}
%% is a function @var{G} of @var{s} defined by the integral below.
%% @example
%% @group
%% syms f(t) s
%% G(s) = rewrite(laplace(f), 'Integral')
%%   @result{} G(s) = (symfun)
%%       ∞
%%       ⌠
%%       ⎮       -s⋅t
%%       ⎮ f(t)⋅ℯ     dt
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%%
%% Example:
%% @example
%% @group
%% syms t
%% f = t^2;
%% laplace(f)
%%   @result{} (sym)
%%       2
%%       ──
%%        3
%%       s
%% @end group
%% @end example
%%
%% By default the ouput is a function of @code{s} (or @code{z} if the Laplace
%% transform happens to be with respect to @code{s}).  This can be overriden
%% by specifying @var{s}.  For example:
%% @example
%% @group
%% syms t s z
%% laplace(exp(t))
%%   @result{} (sym)
%%         1
%%       ─────
%%       s - 1
%% laplace(exp(s))
%%   @result{} (sym)
%%         1
%%       ─────
%%       z - 1
%% laplace(exp(t), z)
%%   @result{} (sym)
%%         1
%%       ─────
%%       z - 1
%% @end group
%% @end example
%%
%% If not specified by @var{t}, the independent variable is chosen by
%% looking for a symbol named @code{t}.  If no such symbol is found,
%% @pxref{@@sym/symvar} is used, which choses a variable close to @code{x}:
%% @example
%% @group
%% syms a y
%% laplace (a*exp (y))
%%   @result{} (sym)
%%         a
%%       ─────
%%       s - 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/ilaplace}
%% @end defmethod

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, integral transforms

function F = laplace(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  f = sym(varargin{1});
  if (nargin == 1 || nargin == 2)
    %% time domain variable not specified
    % if exactly one symbol has char(t) == 't'...
    symbols = findsymbols (f);
    charsyms = cell (size (symbols));
    for c=1:numel(charsyms)
      charsyms{c} = char (symbols{c});
    end
    match = find (strcmp (charsyms, 't'));
    assert (numel (match) <= 1, 'laplace: there is more than one "t" symbol: check symvar(F) and sympy(F)')
    if (~ isempty (match))
      t = symbols{match};  % ... we want that one
    else
      t = symvar (f, 1);
      if (isempty (t))
        t = sym ('t', 'positive');
      end
    end
  end

  % If the physical variable of f is equal to "s",
  % "z" is the frequency domain variable (analogously to SMT)
  if (nargin == 1)
    cmd = { 'f=_ins[0]; t=_ins[1]; s=sp.Symbol("s")'
            'if t==s:'
            '    s=sp.Symbol("z")'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = pycall_sympy__ (cmd, f, t);

  elseif (nargin == 2)
    s = sym(varargin{2});
    cmd = { 'f=_ins[0]; t=_ins[1]; s=_ins[2]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = pycall_sympy__ (cmd, f, t, s);

  elseif (nargin == 3)
    t = sym(varargin{2});
    s = sym(varargin{3});
    cmd = { 'f=_ins[0]; t=_ins[1]; s=_ins[2]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = pycall_sympy__ (cmd, f, t, s);

  else
    print_usage ();

  end

end


%!test
%! % basic
%! syms t s u w
%! assert(logical( laplace(cos(3*t)) == s/(s^2+9) ))
%! assert(logical( laplace(t^3) == 6/s^4 ))

%!test
%! % matlab SMT compat
%! syms t s u w z
%! assert(logical( laplace(exp(2*t)) == 1/(s-2) ))
%! assert(logical( laplace(exp(2*s)) == 1/(z-2) ))
%! assert(logical( laplace(exp(2*u),w) == 1/(w-2) ))
%! assert(logical( laplace(exp(2*u),u,w) == 1/(w-2) ))

%!test
%! syms x s t z
%! % matlab SMT prefers t over x
%! assert (isequal (laplace (x*exp (t), z), x/(z - 1)))
%! % as usual, you can just specify:
%! assert (isequal (laplace(x*exp(t), t, z), x/(z - 1)))  % SMT result
%! assert (isequal (laplace(x*exp(t), x, z), exp(t)/z^2))

%!test
%! syms x a s
%! % if no t, use symvar: take x before a
%! assert (isequal (laplace (a*exp (x)), a/(s - 1)))

%!error <more than one> laplace (sym('t')*sym('t', 'real'))

%!test
%! % constant, issue #250
%! syms s
%! f = laplace(2, s);
%! assert (isequal (f, 2/s))

%!test
%! % Dirac delta and Heaviside tests
%! syms t s
%! assert (isequal (laplace(dirac(t-3)), exp(-3*s)))
%! assert (isequal (laplace((t-3)*heaviside(t-3)), exp(-3*s)/s^2))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms s f(t)
%! assert(logical( laplace(diff(f(t),t),t,s) == s*laplace(f(t),t,s)-f(0) ))
