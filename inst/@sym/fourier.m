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
%% @deftypefn {Function File} {@var{FF} =} fourier (@var{f}, @var{x}, @var{k})
%% @deftypefnx {Function File} {@var{FF} =} fourier (@var{f})
%% @deftypefnx {Function File} {@var{FF} =} fourier (@var{f}, @var{k})
%% Symbolic Fourier transform.
%%
%% Example:
%% @example
%% @group
%% >> syms x
%% >> f = exp(-abs(x));
%% >> fourier(f)
%%    @result{} (sym)
%%        2
%%      ──────
%%       2
%%      w  + 1
%% @end group
%% @end example
%%
%% Note @code{fourier} and @code{ifourier} implement the non-unitary,
%% angular frequency convention.
%%
%% *WARNING*: As of SymPy 0.7.6 (June 2015), there are many problems
%% with fourier transforms, even very simple ones.  Use at your own risk,
%% or even better: help us fix SymPy.
%%
%% @seealso{ifourier}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, integral transforms

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
            'F = sp.transforms._fourier_transform(f, x, k, 1,-1,"Fourier")'
            'return F,'};

    F = python_cmd(cmd, f, x);

  elseif (nargin == 2)
    f = sym(varargin{1});
    k = sym(varargin{2});
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');  % FIXME: should be dummy variable in case k was x
    end
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F = sp.transforms._fourier_transform(f, x, k, 1,-1,"Fourier")'
            'return F,'};

    F = python_cmd(cmd, f, x, k);

  elseif (nargin == 3)
    f = sym(varargin{1});
    x = sym(varargin{2});
    k = sym(varargin{3});
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F = sp.transforms._fourier_transform(f, x, k, 1,-1,"Fourier")'
            'return F,'};

    F = python_cmd(cmd, f, x, k);

  else
    print_usage ();

  end

end


%!test
%! % matlab SMT compatibiliy for arguments
%! syms r x u w v
%! assert(logical( fourier(exp(-abs(x))) == 2/(w^2 + 1) ))
%! assert(logical( fourier(exp(-abs(w))) == 2/(v^2 + 1) ))
%! assert(logical( fourier(exp(-abs(r)),u) == 2/(u^2 + 1) ))
%! assert(logical( fourier(exp(-abs(r)),r,u) == 2/(u^2 + 1) ))

%!test
%! % basic tests
%! syms x w
%! Pi=sym('pi'); assert(logical( fourier(exp(-x^2)) == sqrt(Pi)/exp(w^2/4) ))
%! assert(logical( fourier(x*exp(-abs(x))) == -(w*4*1i)/(w^4 + 2*w^2 + 1) ))

%!xtest
%! % Issue #251, upstream failure?  TODO: upstream issue?
%! syms x w
%! f = fourier(sym(2), x, w);
%! assert (isequal (f, 4*sym(pi)*dirac(w)))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms x w f(x)
%! assert(logical( fourier(diff(f(x),x),x,w) == -1i*w*fourier(f(x),x,w) ))
