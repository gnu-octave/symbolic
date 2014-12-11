%% Copyright (C) 2014 Andrés Prieto
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
%% @deftypefn {Function File} {@var{f} =} ilaplace (@var{F}, @var{s}, @var{t})
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F})
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F}, @var{s})
%% Inverse Laplace transform.
%%
%% Examples:
%% @example
%% syms t s
%% F = 1/s^2
%% ilaplace(F)
%% ilaplace(F, s)
%% ilaplace(F, s, t)
%% @end example
%%
%% @seealso{laplace}
%% @end deftypefn

%% Author: Andrés Prieto
%% Keywords: symbolic, integral transforms

function f = ilaplace(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  % If the Laplace variable in the frequency domain is equal to "t",
  % "x" will be the physical variable (analogously to SMT)
  if (nargin == 1)
    F=varargin{1};
    s=symvar(F,1);
    cmd = { 'F=_ins[0]; s=_ins[1]; t=sp.Symbol("t")'
            'if t==s:'
            '    t=sp.Symbol("x")'
            'return sp.Subs(sp.inverse_laplace_transform(F, s, t),sp.Heaviside(t),1).doit(),'};

    f = python_cmd(cmd,F,s);

  elseif (nargin == 2)
    F=varargin{1};
    s=varargin{2}; 
    cmd = { 'F=_ins[0]; s=_ins[1]; t=sp.Symbol("t")'
            'return sp.Subs(sp.inverse_laplace_transform(F, s, t),sp.Heaviside(t),1).doit(),'};

    f = python_cmd(cmd,F,s);

  elseif (nargin == 3)
    F=varargin{1};
    s=varargin{2};
    t=varargin{3};
    cmd = { 'F=_ins[0];t=_ins[2];s=_ins[1]'
            'return sp.Subs(sp.inverse_laplace_transform(F, s, t),sp.Heaviside(t),1).doit(),'};

    f = python_cmd(cmd,F,s,t);

  else
    error('Wrong number of input arguments') 
 
  endif

end


%!test
%! % basic
%! syms t s r u x
%! assert(logical( ilaplace(1/s^2) == t ))
%! assert(logical( ilaplace(1/r^2,r) == t ))
%! assert(logical( ilaplace(1/s^2,s,u) == u ))
%! assert(logical( ilaplace(1/t^2) == x ))
%! assert(logical( ilaplace(s/(s^2+9)) == cos(3*t) ))
%! assert(logical( ilaplace(6/s^4) == t^3 ))

%!xtest
%! syms s f(t)
%! assert(logical( laplace(diff(f(t),t),t,s) == s*laplace(f(t),t,s)-f(0) ))
