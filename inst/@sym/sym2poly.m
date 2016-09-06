%% Copyright (C) 2003 Willem J. Atsma
%% Copyright (C) 2014-2016 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
%%
%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3, or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied
%% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%% PURPOSE.  See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.  If not,
%% see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypemethod  @@sym {@var{doublec} =} sym2poly (@var{p})
%% @deftypemethodx @@sym {@var{c} =} sym2poly (@var{p}, @var{x})
%% Return a double type vector of coefficients of a symbolic polynomial.
%%
%% In the two-input form, the second argument @var{x} specifies the free
%% variable; in this case this function returns a row vector @var{c} of
%% symbolic expressions. The coefficients correspond to decreasing exponent
%% of the free variable.  Example:
%% @example
%% @group
%% syms x y
%% sym2poly(2*x^2 + 3*x - pi, x)
%%    @result{} ans =
%%   2.0000   3.0000  -3.1416
%% sym2poly(x^2 + y*x, x)
%%    @result{} (sym) [1  y  0]  (1×3 matrix)
%% sym2poly(pi*x^2 + 3*x/2 + exp(sym(1)))
%%    @result{}     3.1416   1.5000   2.7183
%% @end group
%% @end example
%%
%% If you want a symbolic result check the sym2polysane function.
%%
%% If @var{p} is not a polynomial the result has no warranty.  SymPy can
%% certainly deal with more general concepts of polynomial but we do not
%% yet expose all of that here.
%%
%% @seealso{sym2polysane, poly2sym, polyval, roots}
%% @end deftypemethod

%% Created: 18 April 2003
%% Changed: 25 April 2003
%%    Removed the use of differentiate to get to coefficients - round-off
%%     errors cause problems. Now using newly created sumterms().
%% Changed: 6 May 2003
%%    Removed the attempt to use ldegree(), degree() and coeff() - results
%%     with these are inconsistent.
%% Changed: 16 April 2014
%%    Used the comment header and tests in OctSymPy, but rewrote
%%    the body (by Colin Macdonald).

function c = sym2poly(varargin)

  c = sym2polysane(varargin{:});

  if isempty(findsymbols(c))
    c = double(c);
  end

end


%!shared x,y,a,b,c
%! syms x y a b c
%! assert (isequal (sym2poly (x^2 + 3*x - 4), [1 3 -4]))
%! assert (isequal (sym2poly (x^6 - x^3), [1 0 0 -1 0 0 0]))
%! assert (isequal (sym2poly (x^2 + 3*x - 4, x), [1 3 -4]))
%! assert (norm (sym2poly (pi*x^2 + exp(sym(1))) - [pi 0 exp(1)]) < 10*eps)
%! assert (isa (sym2poly (x^2 + 3*x - 4), 'double'))
%! assert (isequal (sym2poly (poly2sym ([1 2 3])), [1 2 3]))
%% types
%% tests with other vars
%! assert (isequal (sym2poly (x^2+y*x, x), [sym(1) y sym(0)]))
%! assert (isequal (sym2poly (x^2+y*x, y), [x x^2]))
%% inverse relationship
%! assert (isequal (sym2poly (poly2sym ([a b c], x), x), [a b c]))
%! assert (isequal (poly2sym (sym2poly(a*x^2 + c, x), x), a*x^2 + c))

%!error <more than one symbol>
%! % too many symbols for single-input
%! p = a*x^2 + 2;
%! c = sym2poly (p);
