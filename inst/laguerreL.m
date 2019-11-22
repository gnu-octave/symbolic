%% Copyright (C) 2008 Eric Chassande-Mottin
%% Copyright (C) 2011 Carnë Draug
%% Copyright (C) 2016, 2018 Colin B. Macdonald
%%
%% This program is free software; you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation; either version 3 of the License, or (at your option) any later
%% version.
%%
%% This program is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public License along with
%% this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defun laguerreL (@var{n}, @var{x})
%% Evaluate Laguerre polynomials.
%%
%% Compute the value of the Laguerre polynomial of order @var{n}
%% for each element of @var{x}.
%% For example, the Laguerre polynomial of order 14 evaluated at
%% the point 6 is
%% @example
%% @group
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% laguerreL (14, 6)
%%   @result{} 0.9765
%% @end group
%% @end example
%%
%% This implementation uses a three-term recurrence directly on the values
%% of @var{x}.  The result is numerically stable, as opposed to evaluating
%% the polynomial using the monomial coefficients.  For example, we can
%% compare the above result to a symbolic construction:
%% @example
%% @group
%% syms x
%% L = laguerreL (14, x);
%% exact = subs (L, x, 6)
%%   @result{} exact = (sym)
%%       34213
%%       ─────
%%       35035
%% @end group
%% @end example
%% If we extract the monomial coefficients and numerically evaluate the
%% polynomial at a point, the result is rather poor:
%% @example
%% @group
%% coeffs = sym2poly (L);
%% @c doctest: +XFAIL_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% polyval (coeffs, 6)
%%   @result{} 0.9765
%% err = ans - double (exact);
%% num2str (err, '%.3g')
%%   @result{} -1.68e-11
%% @end group
%% @end example
%% So please don't do that!  The numerical @code{laguerreL} function
%% does much better:
%% @example
%% @group
%% err = laguerreL (14, 6) - double (exact)
%%   @result{} err = 9.9920e-16
%% @end group
%% @end example
%%
%% @seealso{@@sym/laguerreL}
%% @end defun

function L = laguerreL(n, x)

  if (nargin ~= 2)
    print_usage ();
  end

  if (any (n < 0) || any (mod (n, 1) ~= 0))
    error('second argument "n" must consist of positive integers');
  end

  if (~isscalar (n) && isscalar (x))
    x = x*ones (size (n));
  elseif (~isscalar (n) && ~isscalar (x) && ~isequal (size (n), size (x)))
    error ('inputs must be same size or scalar')
  end

  L0 = ones (size (x), class(x));
  L1 = 1 - x;

  if (isscalar (n))
    if (n == 0)
      L = L0;
    elseif (n == 1)
      L = L1;
    else
      for k = 2:n
        L = (2*k-1-x)/k .* L1 - (k-1)/k * L0;
        L0 = L1;
        L1 = L;
      end
    end
  else
    L = L0;
    L(n >= 1) = L1(n >= 1);
    maxn = max (n(:));
    for k = 2:maxn
      I = (n >= k);  % mask for entries still to be updated
      L(I) = (2*k - 1 - x(I))/k .* L1(I) - (k - 1)/k * L0(I);
      L0 = L1;
      L1 = L;
    end
  end

end


%!assert (isequal (laguerreL (0, rand), 1))

%!test
%! x = rand;
%! assert (isequal (laguerreL (1, x), 1 - x))

%!test
%! x=rand;
%! y1=laguerreL(2, x);
%! p2=[.5 -2 1];
%! y2=polyval(p2,x);
%! assert(y1 - y2, 0, 10*eps);

%!test
%! x=rand;
%! y1=laguerreL(3, x);
%! p3=[-1/6 9/6 -18/6 1];
%! y2=polyval(p3,x);
%! assert(y1 - y2, 0, 20*eps);

%!test
%! x=rand;
%! y1=laguerreL(4, x);
%! p4=[1/24 -16/24 72/24 -96/24 1];
%! y2=polyval(p4,x);
%! assert(y1 - y2, 0, 30*eps)

%!error <positive integer> laguerreL(1.5, 10)
%!error <Invalid call> laguerreL(10)
%!error <same size or scalar> laguerreL([0 1], [1 2 3])
%!error <same size or scalar> laguerreL([0 1], [1; 2])

%!test
%! % numerically stable implementation (in n)
%! L = laguerreL (10, 10);
%! Lex = 1763/63;
%! assert (L, Lex, -eps)
%! L = laguerreL (20, 10);
%! Lex = -177616901779/14849255421;  % e.g., laguerreL(sym(20),10)
%! assert (L, Lex, -eps)

%!test
%! % vectorized x
%! L = laguerreL (2, [5 6 7]);
%! Lex = [3.5 7 11.5];
%! assert (L, Lex, eps)

%!test
%! L = laguerreL (0, [4 5]);
%! assert (L, [1 1], eps)

%!test
%! % vector n
%! L = laguerreL ([0 1 2 3], [4 5 6 9]);
%! assert (L, [1 -4 7 -26], eps)

%!test
%! % vector n, scalar x
%! L = laguerreL ([0 1 2 3], 6);
%! assert (L, [1 -5 7 1], eps)

%!assert (isa (laguerreL (0, single (1)), 'single'))
%!assert (isa (laguerreL (1, single ([1 2])), 'single'))
%!assert (isa (laguerreL ([1 2], single ([1 2])), 'single'))
