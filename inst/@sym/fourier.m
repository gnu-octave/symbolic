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
%% Symbolic inverse Fourier transform (non-unitary, angular frequency).
%%
%% Example:
%% @example
%% @group
<<<<<<< HEAD
%% >> syms k
%% >> F = pi*exp(-k^2/4);
%% >> ifourier(F)
=======
%% >> syms x
%% >> f = exp(-abs(x));
%% >> fourier(f)
>>>>>>> octsympy_colin/master
%%    @result{} (sym)
%%            2
%%          -x
%%      √π⋅ℯ
%% @end group
%% @group
%% >> F = 2*sym(pi)*dirac(k);
%% >> ifourier(F)
%%    @result{} ans = (sym) 1
%% @end group
%% @end example
%%
%% @seealso{fourier}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, integral transforms

function f = ifourier(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

<<<<<<< HEAD
  % If the physical variable of f is equal to "s",
  % "t" is the frequency domain variable (analogously to SMT)
  if (nargin == 1)
    F=varargin{1};
    k=symvar(F,1);
    cmd = { 'F=_ins[0]; k=_ins[1]; x=sp.Symbol("x")'
            'if x==k:'
            '    x=sp.Symbol("t")'
            'f = sp.inverse_fourier_transform(F, k, x/(2*sp.pi))/(2*sp.pi)'
            'return f,'};
=======
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
            'F = sp.fourier_transform(f, x, k/(2*sp.pi))'
            'return F,'};
>>>>>>> octsympy_colin/master

    f = python_cmd(cmd, F, k);

  elseif (nargin == 2)
<<<<<<< HEAD
    F=varargin{1};
    x=varargin{2};
    k=symvar(F,1);
    cmd = { 'F=_ins[0]; k=_ins[1]; x=_ins[2]'
            'f = sp.inverse_fourier_transform(F, k, x/(2*sp.pi))/(2*sp.pi)'
            'return f,'};
=======
    f = sym(varargin{1});
    k = sym(varargin{2});
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');  % FIXME: should be dummy variable in case k was x
    end
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F = sp.fourier_transform(f, x, k/(2*sp.pi))'
            'return F,'};
>>>>>>> octsympy_colin/master

    f = python_cmd(cmd, F, k, x);

  elseif (nargin == 3)
<<<<<<< HEAD
    F=varargin{1};
    k=varargin{2};
    x=varargin{3};
    cmd = { 'F=_ins[0]; k=_ins[1]; x=_ins[2]'
            'f = sp.inverse_fourier_transform(F, k, x/(2*sp.pi))/(2*sp.pi)'
            'return f,'};
=======
    f = sym(varargin{1});
    x = sym(varargin{2});
    k = sym(varargin{3});
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F = sp.fourier_transform(f, x, k/(2*sp.pi))'
            'return F,'};
>>>>>>> octsympy_colin/master

    f = python_cmd(cmd, F, k, x);

  else
    print_usage ();

  end

end


%!test
<<<<<<< HEAD
%! % matlab SMT compat
%! syms t r u x w
%! Pi=sym('pi');
%! assert(logical( ifourier(exp(-abs(w))) == 1/(Pi*(x^2 + 1)) ))
%! assert(logical( ifourier(exp(-abs(x))) == 1/(Pi*(t^2 + 1)) ))
%! assert(logical( ifourier(exp(-abs(r)),u) == 1/(Pi*(u^2 + 1)) ))
%! assert(logical( ifourier(exp(-abs(r)),r,u) == 1/(Pi*(u^2 + 1)) ))
=======
%! % matlab SMT compatibiliy for arguments
%! syms r x u w v
%! assert(logical( fourier(exp(-abs(x))) == 2/(w^2 + 1) ))
%! assert(logical( fourier(exp(-abs(w))) == 2/(v^2 + 1) ))
%! assert(logical( fourier(exp(-abs(r)),u) == 2/(u^2 + 1) ))
%! assert(logical( fourier(exp(-abs(r)),r,u) == 2/(u^2 + 1) ))
>>>>>>> octsympy_colin/master

%!test
%! % basic
%! syms x w
%! Pi=sym('pi');
%! assert(logical( ifourier(exp(-w^2/4)) == 1/(sqrt(Pi)*exp(x^2)) ))
%! assert(logical( ifourier(sqrt(Pi)/exp(w^2/4)) == exp(-x^2) ))

%!xtest
<<<<<<< HEAD
%! % Inverse Fourier transform cannot handle non-smooth functions
%! % SymPy cannot evaluate correctly??
%! syms x w
%! assert(logical( ifourier(2/(w^2 + 1)) == exp(-abs(x)) ))
%! assert(logical( ifourier(2/(w^2 + 1)) == heaviside(x)/exp(x) + heaviside(-x)*exp(x) ))
%! assert(logical( ifourier(-(w*4)/(w^4 + 2*w^2 + 1) )== -x*exp(-abs(x))*1i ))
%! assert(logical( ifourier(-(w*4)/(w^4 + 2*w^2 + 1) )== -x*(heaviside(x)/exp(x) + heaviside(-x)*exp(x))*1i ))
=======
%! % Issue #251, upstream failure?  TODO: upstream issue?
%! syms x w
%! f = fourier(sym(2), x, w);
%! assert (isequal (f, 4*sym(pi)*dirac(w)))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms x w f(x)
%! assert(logical( fourier(diff(f(x),x),x,w) == -1i*w*fourier(f(x),x,w) ))
>>>>>>> octsympy_colin/master
