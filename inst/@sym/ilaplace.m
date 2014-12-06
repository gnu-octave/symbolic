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
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F}, @var{s}, @var{t})
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F}, @var{s})
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F})
%% Inverse Laplace transform.
%%
%% Examples:
%% @example
%% syms t s
%% F = 1/s^2
%% ilaplace(F)
%% ilaplace(F,s)
%% ilaplace(F,s,t)
%% @end example
%%
%% @seealso{ilaplace}
%% @end deftypefn

%% Author: Andrés Prieto
%% Keywords: symbolic, integral transforms

function f = ilaplace(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  if(nargin==1)
    F=varargin{1};
    cmd = { 'F=_ins[0]'
            't=sp.Symbol("t")'
            's=list(F.free_symbols)[0]'
            'return sp.inverse_laplace_transform(F, s, t),'};

    f = python_cmd(cmd,F);

  elseif(nargin==2)
    F=varargin{1};
    s=varargin{2}; 
    cmd = { 'F=_ins[0]'
            't=sp.Symbol("t")'
            's=_ins[1]'
            'return sp.inverse_laplace_transform(F, s, t),'};

    f = python_cmd(cmd,F,s);

  elseif(nargin==3)
    F=varargin{1};
    s=varargin{2};
    t=varargin{3};
    cmd = { 'F=_ins[0]'
            't=_ins[2]'
            's=_ins[1]'
            'return sp.inverse_laplace_transform(F, s, t),'};

    f = python_cmd(cmd,F,s,t);

  else
    error('Wrong number of input arguments') 
 
  endif

end

%!shared t,s
%! syms t s

%!test
%! % basic
%! assert(logical( ilaplace(1/s^2) == t*heaviside(t) ))
%! assert(logical( ilaplace(cos(3*t)) == s/(s^2+9) ))
%! assert(logical( ilaplace(t^3) == 6/s^4 ))

%!xtest
%! syms t s f(t)
%! assert(logical( laplace(diff(f(t),t),t,s) == s*laplace(f(t),t,s)-f(0) ))


