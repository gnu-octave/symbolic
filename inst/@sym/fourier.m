%% Copyright (C) 2014, 2015 Andrés Prieto, Colin B. Macdonald
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
%% Symbolic Fourier transform (non-unitary, angular frequency).
%%
%% Example:
%% @example
%% @group
%% >> syms x
%% >> f = exp(-abs(t));
%% >> fourier(f)
%%    @result{} (sym)
%%     2   
%%   ──────
%%    2    
%%   w  + 1  
%% @end group
%% @end example
%%
%% @seealso{ifourier}
%% @end deftypefn

%% Author: Colin B. Macdonald, Andrés Prieto
%% Keywords: symbolic, integral transforms

function F = fourier(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  % If the physical variable of f is equal to "w",
  % "t" is the frequency domain variable (analogously to SMT)
  if (nargin == 1)
    f=varargin{1};
    x=symvar(f,1);
    cmd = { 'f=_ins[0]; x=_ins[1]; k=sp.Symbol("w")'
            'if x==k:'
            '    k=sp.Symbol("t")'
            'F = sp.fourier_transform(f, x, k/(2*sp.pi))'
            'return F,'};

    F = python_cmd(cmd, f, x);

  elseif (nargin == 2)
    f=varargin{1};
    k=varargin{2}; 
    x=symvar(f,1);
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F = sp.fourier_transform(f, x, k/(2*sp.pi))'
            'return F,'};

    F = python_cmd(cmd, f, x, k);

  elseif (nargin == 3)
    f=varargin{1};
    x=varargin{2}; 
    k=varargin{3};
    cmd = { 'f=_ins[0]; x=_ins[1]; k=_ins[2]'
            'F = sp.fourier_transform(f, x, k/(2*sp.pi))'
            'return F,'};

    F = python_cmd(cmd, f, x, k);

  else
    print_usage ();

  end

end


%!test
%! % basic
%! syms r x u w
%! assert(logical( fourier(exp(-abs(x))) == 2/(w^2 + 1) ))
%! assert(logical( fourier(exp(-abs(w))) == 2/(t^2 + 1) ))
%! assert(logical( fourier(exp(-abs(r)),u) == 2/(u^2 + 1) ))
%! assert(logical( fourier(exp(-abs(r)),r,u) == 2/(u^2 + 1) ))
%! Pi=sym('pi'); assert(logical( fourier(exp(-x^2)) == sqrt(Pi)/exp(w^2/4) ))
%! assert(logical( fourier(x*exp(-abs(x))) == -(w*4*1i)/(w^4 + 2*w^2 + 1) ))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms x w f(x)
%! assert(logical( fourier(diff(f(x),x),x,w) == -1i*w*fourier(f(x),x,w) ))
