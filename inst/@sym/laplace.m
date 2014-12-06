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
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f}, @var{t}, @var{s})
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f}, @var{t})
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f})
%% Laplace transform.
%%
%% Examples:
%% @example
%% syms t s
%% f = t^2
%% laplace(f)
%% laplace(f,t)
%% laplace(f,t,s)
%% @end example
%%
%% @seealso{ilaplace}
%% @end deftypefn

%% Author: Andrés Prieto
%% Keywords: symbolic, integral transforms

function F = laplace(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  if(nargin==1)
    f=varargin{1};
    cmd = { 'f=_ins[0]'
            's=sp.Symbol("s")'
            't=list(f.free_symbols)[0]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd,f);

  elseif(nargin==2)
    f=varargin{1};
    t=varargin{2}; 
    cmd = { 'f=_ins[0]'
            's=sp.Symbol("s")'
            't=_ins[1]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd,f,t);

  elseif(nargin==3)
    f=varargin{1};
    t=varargin{2}; 
    s=varargin{3};
    cmd = { 'f=_ins[0]'
            's=_ins[2]'
            't=_ins[1]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd,f,t,s);

  else
    error('Wrong number of input arguments') 
 
  endif

end

%!shared t,s
%! syms t s

%!test
%! % basic
%! assert(logical( laplace(exp(2*t)) == 1/(s-2) ))
%! assert(logical( laplace(cos(3*t)) == s/(s^2+9) ))
%! assert(logical( laplace(t^3) == 6/s^4 ))

%!xtest
%! syms t s f(t)
%! assert(logical( laplace(diff(f(t),t),t,s) == s*laplace(f(t),t,s)-f(0) ))


