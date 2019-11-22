%% Copyright (C) 2003 Willem J. Atsma
%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% Return vector of coefficients of a symbolic polynomial.
%%
%% In the two-input form, the second argument @var{x} specifies the free
%% variable; in this case this function returns a row vector @var{c} of
%% symbolic expressions. The coefficients correspond to decreasing exponent
%% of the free variable.  Example:
%% @example
%% @group
%% syms x y
%% sym2poly(2*x^2 + 3*x - pi, x)
%%    @result{} (sym) [2  3  -π]  (1×3 matrix)
%% sym2poly(x^2 + y*x, x)
%%    @result{} (sym) [1  y  0]  (1×3 matrix)
%% @end group
%% @end example
%%
%% @strong{Warning}: Using the single-argument form, the coefficient vector
%% @var{c} is a plain numeric vector (double).  This is for compatibility
%% with the Matlab Symbolic Math Toolbox.
%% We suggest making this clear in your code by explicitly casting to @code{double},
%% as in:
%% @example
%% @group
%% syms x
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% double(sym2poly(pi*x^3 + 3*x/2 + exp(sym(1))))
%%    @result{}     3.1416      0   1.5000   2.7183
%% @end group
%% @end example
%% You may prefer specifying @var{X} or using @code{coeffs}:
%% @example
%% @group
%% coeffs(pi*x^3 + 3*x/2 + exp(sym(1)), 'all')
%%    @result{} (sym) [π  0  3/2  ℯ]  (1×4 matrix)
%% @end group
%% @end example
%%
%% If @var{p} is not a polynomial the result has no warranty.  SymPy can
%% certainly deal with more general concepts of polynomial but we do not
%% yet expose all of that here.
%%
%% @seealso{poly2sym, @@sym/coeffs, polyval, roots}
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

function c = sym2poly(p, x)

  if ~(isscalar(p))
    error ('sym2poly: works for scalar input only');
  end

  if (nargin == 1)
    ss = findsymbols(p);
    if (length (ss) >= 2)
      error ('sym2poly: input has more than one symbol: not clear what you want me to do')
    elseif (length (ss) == 1)
      x = ss{1};
    else
      x = sym('x');
    end
    convert_to_double = true;
  elseif (nargin == 2)
    convert_to_double = false;
  else
    print_usage ();
  end

  cmd = { 'f = _ins[0]'
          'x = _ins[1]'
          'p = Poly.from_expr(f,x)'
          'return p.all_coeffs(),' };

  c2 = pycall_sympy__ (cmd, sym(p), sym(x));
  if (isempty(c2))
    error ('sym2poly: empty python output, can this happen?  A bug.')
  end

  % FIXME: should be able to convert c2 to array faster than array
  % expansion!  Particularly in the case where we just convert to
  % double anyway!
  c = sym([]);
  for j = 1:numel(c2)
    % Bug #17
    %c(j) = c2{j};
    idx.type = '()'; idx.subs = {j};
    c = subsasgn(c, idx, c2{j});
  end

  if (convert_to_double)
    c = double(c);
  end

end


%!shared x,y,a,b,c
%! syms x y a b c
%!assert (isequal (sym2poly (x^2 + 3*x - 4), [1 3 -4]))
%!assert (isequal (sym2poly (x^6 - x^3), [1 0 0 -1 0 0 0]))
%!assert (isequal (sym2poly (x^2 + 3*x - 4, x), [1 3 -4]))
%!assert (norm (sym2poly (pi*x^2 + exp(sym(1))) - [pi 0 exp(1)]) < 10*eps)
%% types
%!assert (isa (sym2poly (x^2 + 3*x - 4), 'double'))
%!assert (isa (sym2poly (x^2 + 3*x - 4, x), 'sym'))
%% tests with other vars
%!assert (isequal (sym2poly (x^2+y*x, x), [sym(1) y sym(0)]))
%!assert (isequal (sym2poly (x^2+y*x, y), [x x^2]))
%% inverse relationship
%!assert (isequal (sym2poly (poly2sym ([a b c], x), x), [a b c]))
%!assert (isequal (poly2sym (sym2poly(a*x^2 + c, x), x), a*x^2 + c))
%!assert (isequal (sym2poly (poly2sym ([1 2 3])), [1 2 3]))

%!error <more than one symbol>
%! % too many symbols for single-input
%! p = a*x^2 + 2;
%! c = sym2poly (p);

%!assert (isequal (sym2poly (sym(5)), sym(5)))
