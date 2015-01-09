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
%% @deftypefn  {Function File} {@var{y} =} symprod (@var{f}, @var{n}, @var{a}, @var{b})
%% @deftypefnx {Function File} {@var{y} =} symprod (@var{f}, @var{n}, [@var{a}, @var{b}])
%% @deftypefnx {Function File} {@var{y} =} symprod (@var{f}, [@var{a}, @var{b}])
%% Symbolic product.
%%
%% FIXME: symprod(f, [a b]), other calling forms
%%
%% FIXME: revisit witn sympy 0.7.5:
%% @example
%% symprod(q,n,1,oo )
%% ans = [sym] q**oo
%% 0^oo
%% ans = [sym] 0
%% @end example
%%
%% @seealso{symsum, prod}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function S = symprod(f, n, a, b)

  % FIXME: symvar
  %if (nargin == 3)
  %  n = symvar

  cmd = { '(f, n, a, b) = _ins'
          'S = sp.product(f, (n, a, b))'
          'return S,' };

  S = python_cmd (cmd, sym(f), sym(n), sym(a), sym(b));

end


%!test
%! % simple
%! syms n
%! assert (isequal (symprod(n, n, 1, 10), factorial(sym(10))))
%! assert (isequal (symprod(n, n, sym(1), sym(10)), factorial(10)))

%!test
%! % infinite product
%! syms a n oo
%! zoo = sym('zoo');
%! assert (isequal (symprod(a, n, 1, oo), a^oo))
%! assert (isequal (symprod(a, n, 1, inf), a^oo))

%%!test
%%! % SymPy 0.7.6: nan
%%! % SymPy git: interesting that 1**oo is nan but this is still 1
%%! assert (isequal (symprod(1, n, 1, oo), sym(1)))
