%% Copyright (C) 2014 Andrés Prieto
%% Copyright (C) 2015 Andrés Prieto, Colin Macdonald
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
%% @deftypefn {Function File} {@var{F} =} laplace (@var{f}, @var{t}, @var{s})
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f})
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f}, @var{s})
%% Laplace transform.
%%
%% Example:
%% @example
%% @group
%% >> syms t
%% >> f = t^2;
%% >> laplace(f)
%%    @result{} (sym)
%%        2
%%        ──
%%         3
%%        s
%% @end group
%% @end example
%%
%% By default the ouput is a function of @code{s} (or @code{z} if the Laplace
%% transform happens to be with respect to @code{s}).  This can be overriden
%% by specifying @var{s}.  For example:
%% @example
%% @group
%% >> syms t s z
%% >> laplace(exp(t))
%%    @result{} (sym)
%%        1
%%      ─────
%%      s - 1
%% >> laplace(exp(s))
%%    @result{} (sym)
%%        1
%%      ─────
%%      z - 1
%% >> laplace(exp(t), z)
%%    @result{} (sym)
%%        1
%%      ─────
%%      z - 1
%% @end group
%% @end example
%%
%% @seealso{ilaplace}
%% @end deftypefn

%% Author: Andrés Prieto
%% Keywords: symbolic, integral transforms

function F = laplace(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  % If the physical variable of f is equal to "s",
  % "z" is the frequency domain variable (analogously to SMT)
  if (nargin == 1)
    f = sym(varargin{1});
    t = symvar(f, 1);
    if (isempty(t))
      t = sym('t');
    end
    cmd = { 'f=_ins[0]; t=_ins[1]; s=sp.Symbol("s")'
            'if t==s:'
            '    s=sp.Symbol("z")'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd, f, t);

  elseif (nargin == 2)
    f = sym(varargin{1});
    s = sym(varargin{2});
    t = symvar(f, 1);  % note SMT does something different, prefers t
    if (isempty(t))
      t = sym('t');
    end
    cmd = { 'f=_ins[0]; t=_ins[1]; s=_ins[2]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd, f, t, s);

  elseif (nargin == 3)
    f = sym(varargin{1});
    t = sym(varargin{2});
    s = sym(varargin{3});
    cmd = { 'f=_ins[0]; t=_ins[1]; s=_ins[2]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd, f, t, s);

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
%! % matlab SMT prefers t over x (WTF not symvar like we do?)
%! assert (isequal (laplace(x*exp(t), z), exp(t)/z^2))
%! % as usual, you can just specify:
%! assert (isequal (laplace(x*exp(t), t, z), x/(z - 1)))  % SMT result
%! assert (isequal (laplace(x*exp(t), x, z), exp(t)/z^2))

%!test
%! % constant, issue #250
%! syms s
%! f = laplace(2, s);
%! assert (isequal (f, 2/s))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms s f(t)
%! assert(logical( laplace(diff(f(t),t),t,s) == s*laplace(f(t),t,s)-f(0) ))
