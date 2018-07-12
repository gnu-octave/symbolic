%% Copyright (C) 2014-2016, 2018 Colin B. Macdonald
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
%% @defmethod  @@sym mod (@var{x}, @var{n})
%% @defmethodx @@sym mod (@var{x}, @var{n}, false)
%% Element-wise modular arithmetic on symbolic arrays and polynomials.
%%
%% Example:
%% @example
%% @group
%% mod([10 3 1], sym(3))
%%   @result{} ans = (sym) [1  0  1]  (1×3 matrix)
%% @end group
%% @end example
%%
%% If any of the entries contain variables, we assume they are
%% univariate polynomials and convert their coefficients to mod
%% @var{n}:
%% @example
%% @group
%% syms x
%% mod(5*x + 7, 3)
%%   @result{} (sym) 2⋅x + 1
%% mod(x, 3)   % (coefficient is 1 mod 3)
%%   @result{} (sym) x
%% @end group
%% @end example
%% You can disable this behaviour by passing @code{false} as the
%% third argument:
%% @example
%% @group
%% q = mod(x, 3, false)
%%   @result{} q = (sym) x mod 3
%% subs(q, x, 10)
%%   @result{} ans = (sym) 1
%%
%% syms n integer
%% mod(3*n + 2, 3, false)
%%   @result{} (sym) 2
%% @end group
%% @end example
%%
%% @seealso{@@sym/coeffs}
%% @end defmethod


function z = mod(x, n, canpoly)

  if (nargin > 3)
    print_usage ();
  end

  if (nargin < 3)
    canpoly = true;
  end

  isconst = isempty (findsymbols (x));

  if (~canpoly || isconst)
    z = elementwise_op ('lambda a,b: a % b', sym(x), sym(n));

  else
    %% its not constant, assume everything is poly and mod the coefficients
    z = x;
    for i = 1:numel(x)
      % t = x(i)
      idx.type = '()'; idx.subs = {i};
      t = subsref (x, idx);
      if (isscalar(n))
        m = n;
      else
        m = subsref (n, idx); % m = n(i)
      end
      sv = symvar(t, 1);
      % Note: sympy Polys have a .termwise: would that be easier?
      [c, t] = coeffs(t, sv);
      c = mod(c, m, false);  % force no poly here
      rhs = t * c.';  % recombine the new poly
      z = subsasgn(z, idx, rhs);  %z(i) = rhs;
    end
  end

end


%!error <Invalid> mod (sym(1), 2, 3 ,4)

%!assert (isequal (mod (sym(5), 4), sym(1)))
%!assert (isequal (mod ([sym(5) 8], 4), [1 0] ))
%!assert (isequal (mod (sym(5), [2 3]), [1 2] ))
%!assert (isequal (mod ([sym(5) sym(6)], [2 3]), [1 0] ))

%!test
%! syms x
%! assert (isequal ( mod (5*x, 3), 2*x ))

%!test
%! syms x
%! a = [7*x^2 + 3*x + 3  3*x; 13*x^4  6*x];
%! assert (isequal ( mod (a,3), [x^2 0; x^4 0] ))

%!test
%! % vector of polys with mix of vars: symvar on each
%! syms x y
%! a = [6*x  7*y];
%! b = mod(a, 4);
%! c = [2*x  3*y];
%! assert (isequal (b, c))

%!test
%! % coeff has variable
%! syms x
%! n = sym('n', 'integer');
%! p = (3*n + 2)*x;
%! q = mod(p, 3);
%! assert (isequal (q, 2*x))

%!test
%! % coeff has variable
%! syms x a
%! p = a*x;
%! q = mod(p, 3);
%! q = children(q);
%! q = q(2);  % order might be fragile!
%! w = subs(q, a, 5);
%! assert (isequal (w, 2))

%!test
%! % different modulo
%! syms x y
%! q = mod([5*x + 10  5*y + 10], [2 3]);
%! assert (isequal (q, [x  2*y + 1]))
