%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn  {Function File}  {@var{q}, @var{r}} quorem (@var{x}, |var{y})
%% Quotient and remainder of a symbolic integer or polynomial
%%
%% @seealso{factor}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [q, r] = quorem(a, b)

  if (isempty (findsymbols (a)) && isempty (findsymbols (b)))
    %% Integers
    cmd = { '(a, b) = _ins'
            'r = a % b'
            'q = Integer(a/b)'
            'assert a == q*b + r'
            'return (q, r)' };
    [q, r] = python_cmd (cmd, sym(a), sym(b));

  else
    %% polynomial

    cmd = { 'a, b = _ins'
            'q, r = div(a, b, domain=QQ)'
            '#assert a == q*b + r'
            'return (q, r)' };
    [q, r] = python_cmd (cmd, sym(a), sym(b));

  end
end


%%ml
%syms x y
%factor(x^3-y^3)
%(x - y)*(x^2 + x*y + y^2)

%syms a b
%factor([a^2 - b^2, a^3 + b^3])
% [ (a - b)*(a + b), (a + b)*(a^2 - a*b + b^2)]


%!test
%! a = sym(17); b = sym(4);
%! [q, r] = quorem(a, b);
%! assert (isa (q, 'sym'))
%! assert (isa (r, 'sym'))
%! assert (isequal (a, q*b + r))
%! assert (isequal (q, 4))
%! assert (isequal (r, 1))

%!test
%! a = sym(1764)**256; b = sym(137);
%! [q, r] = quorem(a, b);
%! assert (isequal (a, q*b + r))

%!test
%! syms x
%! a = 2*(x+1)*(x-2); b = x+1;
%! [q, r] = quorem(a, b)
%! assert (isequal (a, q*b + r))
%! assert (isequal (q, 2))
%! assert (isequal (r, x-2))


%%test
%% %%ml
%% syms x y
%factor(x^3-y^3)
%(x - y)*(x^2 + x*y + y^2)

