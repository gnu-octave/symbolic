%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{g} =} int (@var{f})
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, @var{x}, @var{a}, @var{b})
%% Symbolic integration.
%%
%% The definite integral: to integrate an expression @var{f} with
%% respect to variable @var{x} from @var{x}=0 to @var{x}=2 is:
%% @example
%% F = int(f, x, 0, 2)
%% @end example
%%
%% Indefinite integral:
%% @example
%% F = int(f, x)
%% F = int(f)
%% @end example
%%
%% @seealso{diff}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, integration

function z = int(f,x,a,b)

  if nargin == 1
    cmd = [ '(f,) = _ins\n'  ...
            'd = sp.integrate(f)\n'  ...
            'return (d,)' ];
    z = python_cmd (cmd, sym(f));

  elseif nargin == 2
    cmd = [ '(f,x) = _ins\n'  ...
            'd = sp.integrate(f, x)\n'  ...
            'return (d,)' ];
    z = python_cmd (cmd, sym(f), sym(x));

  elseif nargin == 4
    cmd = [ '(f,x,a,b) = _ins\n'  ...
            'd = sp.integrate(f, (x, a, b))\n'  ...
            'return (d,)' ];
    z = python_cmd (cmd, sym(f), sym(x), sym(a), sym(b));
  end

end


%!shared x,y,a
%! syms x y a
%!assert(logical(int(cos(x)) - sin(x) == 0))
%!assert(logical(int(cos(x),x) - sin(x) == 0))
%!assert(logical(int(cos(x),x,0,1) - sin(sym(1)) == 0))

%!test
%! %% limits might be syms
%! assert( isequal (int(cos(x),x,sym(0),sym(1)), sin(sym(1))))
%! assert( isequal (int(cos(x),x,0,a), sin(a)))

%!test
%! %% other variables present
%! assert( isequal (int(y*cos(x),x), y*sin(x)))
