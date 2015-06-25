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
%% @deftypefn {Function File} {@var{f} =} ilaplace (@var{F}, @var{s}, @var{t})
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F})
%% @deftypefnx {Function File} {@var{f} =} ilaplace (@var{F}, @var{t})
%% Inverse Laplace transform.
%%
%% Example:
%% @example
%% @group
%% >> syms s
%% >> F = 1/s^2;
%% >> ilaplace(F)
%%    @result{} (sym) t
%% @end group
%% @end example
%%
%% By default the ouput is a function of @code{t} (or @code{x} if the
%% inverse transform happens to be with respect to @code{t}).  This can
%% be overriden by specifying @var{t}.  For example:
%% @example
%% @group
%% >> syms s t x
%% >> ilaplace(1/s^2)
%%    @result{} (sym) t
%% >> ilaplace(1/t^2)
%%    @result{} (sym) x
%% >> ilaplace(1/s^2, x)
%%    @result{} (sym) x
%% @end group
%% @end example
%%
%% @seealso{laplace}
%% @end deftypefn

%% Author: Andrés Prieto
%% Keywords: symbolic, integral transforms

function f = ilaplace(varargin)

  % FIXME: it only works for scalar functions

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
    t=varargin{2};
    s=symvar(F,1);
    cmd = { 'F=_ins[0]; s=_ins[1]; t=_ins[2]'
            'return sp.Subs(sp.inverse_laplace_transform(F, s, t),sp.Heaviside(t),1).doit(),'};

    f = python_cmd(cmd,F,s,t);

  elseif (nargin == 3)
    F=varargin{1};
    s=varargin{2};
    t=varargin{3};
    cmd = { 'F=_ins[0]; s=_ins[1]; t=_ins[2]'
            'return sp.Subs(sp.inverse_laplace_transform(F, s, t),sp.Heaviside(t),1).doit(),'};

    f = python_cmd(cmd,F,s,t);

  else
    print_usage ();

  end

end


%!test
%! % basic
%! syms t s r u x
%! assert(logical( ilaplace(1/r^2,u) == u ))
%! assert(logical( ilaplace(1/r^2,r,u) == u ))
%! assert(logical( ilaplace(s/(s^2+9)) == cos(3*t) ))
%! assert(logical( ilaplace(6/s^4) == t^3 ))

%!test
%! % SMT compact
%! syms t s x
%! assert(logical( ilaplace(1/s^2) == t ))
%! assert(logical( ilaplace(1/t^2) == x ))
