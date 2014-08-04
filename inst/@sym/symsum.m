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
%% @deftypefn  {Function File} {@var{y} =} symsum (@var{f}, @var{n}, @var{a}, @var{b})
%% @deftypefnx {Function File} {@var{y} =} symsum (@var{f}, @var{n}, [@var{a}, @var{b}])
%% @deftypefnx {Function File} {@var{y} =} symsum (@var{f}, [@var{a}, @var{b}])
%% Symbolic summation.
%%
%% FIXME: symsum(f, [a b]), other calling forms
%%
%% @seealso{symprod, sum}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function S = symsum(f,n,a,b)

  %if (nargin == 3)
  %  n = symvar

  cmd = [ '(f,n,a,b) = _ins\n'  ...
           'S = sp.summation(f,(n,a,b))\n'  ...
           'return (S,)' ];
  S = python_cmd (cmd, sym(f), sym(n), sym(a), sym(b));

end


%!shared n,oo
%! syms n
%! oo = sym(inf);

%!test
%! % finite sums
%! assert (isequal (symsum(n,n,1,10), 55))
%! assert(isa(symsum(n,n,1,10), 'sym'))
%! assert (isequal (symsum(n,n,sym(1),sym(10)), 55))
%! assert (isequal (symsum(n,n,sym(1),sym(10)), 55))
%! assert (isequal (symsum(1/n,n,1,10), sym(7381)/2520))

%!test
%! % ok to use double's for arguments in infinite series
%! assert(isequal(symsum(1/n^2,n,1,oo), sym(pi)^2/6))
%! assert(isequal(symsum(1/n^2,n,1,inf), sym(pi)^2/6))

%!test
%! % should be oo because 1 is real but seems to be
%! % zoo/oo depending on sympy version
%! zoo = sym('zoo');
%! assert (isequal (symsum(1/n,n,1,oo), oo) || ...
%!         isequal (symsum(1/n,n,1,oo), zoo))
