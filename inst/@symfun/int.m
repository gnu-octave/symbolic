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
%% @deftypefn  {Function File} {@var{g} =} int (@var{f})
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, @var{x}, @var{a}, @var{b})
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, @var{x}, [@var{a}, @var{b}])
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, @var{a}, @var{b})
%% @deftypefnx {Function File} {@var{g} =} int (@var{f}, [@var{a}, @var{b}])
%% Symbolic integration of a symfun.
%%
%% Indefinite integrals of a symfun returns a symfun.  Definite
%% integrals return a sym.
%%
%% See help for sym int.
%%
%% @seealso{diff}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, integration

function F = int(f, varargin)

  if (nargin == 1)
    indefinite = true;
  elseif (nargin == 2) && (numel(varargin{1}) == 1)
    % "int(f, x)" but not "int(f, [a b])"
    indefinite = true;
  else
    indefinite = false;
  end

  F = int(f.sym, varargin{:});
  if (indefinite)
    F = symfun(F, f.vars);
  end

end


%!test
%! % indefinite integral of symfun gives symfun
%! syms x
%! f(x) = x^2;
%! g = int(f);
%! assert (isa(g, 'symfun'))
%! g = int(f, x);
%! assert (isa(g, 'symfun'))

%!test
%! % indefinite integral of abstract symfun gives symfun
%! syms f(x)
%! g = int(f);
%! assert (isa(g, 'symfun'))
%! g = int(f, x);
%! assert (isa(g, 'symfun'))

%!test
%! % definite integral does not give symfun
%! syms x
%! f(x) = x^2;
%! g = int(f, x, 0, 2);
%! assert (isa(g, 'sym'))
%! assert (~isa(g, 'symfun'))

%!test
%! % ... even if it has a variable in it
%! syms x t
%! f(x) = x;
%! g = int(f, x, 0, t);
%! assert (isa(g, 'sym'))
%! assert (~isa(g, 'symfun'))

%!test
%! % ... even if the input is abstract funcion
%! syms f(x)
%! g = int(f, x, 0, 2);
%! assert (isa(g, 'sym'))
%! assert (~isa(g, 'symfun'))

%!test
%! % symfun in x, integrated in y gives symfun still in x
%! % (SMT does this too).
%! syms f(x) y
%! g = int(f, y);
%! assert (isa (g, 'symfun'))
%! assert (isequal (argnames (g), x))

%!test
%! % same as above, but concrete symfun
%! syms x y
%! f(x) = x^2;
%! g = int(f, y);
%! assert (isa (g, 'symfun'))
%! assert (isequal (argnames (g), x))
%! assert (isequal (g, x^2*y))
