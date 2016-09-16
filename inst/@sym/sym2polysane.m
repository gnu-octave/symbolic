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
%% @deftypemethod  @@sym sym2polysane (@var{p})
%% @deftypemethodx @@sym sym2polysane (@var{p}, @var{x})
%% Return vector of coefficients of a symbolic polynomial.
%%
%% In the two-input form, the second argument @var{x} specifies the free
%% variable; in this case this function returns a row vector @var{c} of
%% symbolic expressions. The coefficients correspond to decreasing exponent
%% of the free variable.  Example:
%% @example
%% @group
%% syms x y
%% sym2polysane(2*x^2 + 3*x - pi, x)
%%    @result{} (sym) [2  3  -π]  (1×3 matrix)
%% sym2polysane(x^2 + y*x, x)
%%    @result{} (sym) [1  y  0]  (1×3 matrix)
%% sym2polysane(pi*x^2 + 3*x/2 + exp(sym(1)))
%%    @result{} (sym) [π  3/2  ℯ]  (1×3 matrix)
%% @end group
%% @end example
%%
%% If @var{p} is not a polynomial the result has no warranty.  SymPy can
%% certainly deal with more general concepts of polynomial but we do not
%% yet expose all of that here.
%%
%% @seealso{sym2poly, poly2sym, polyval, roots}
%% @end deftypemethod


function c = sym2polysane(p, x)

  if ~(isscalar(p))
    error('works for scalar input only');
  end

  ss = findsymbols(p);
  if (nargin == 1)
    if (length(ss) >= 2)
      error('Input has more than one symbol: not clear what you want me to do')
    end
    x = ss{1};
  elseif (nargin > 2)
    print_usage ();
  end

  cmd = { 'f = _ins[0]'
          'x = _ins[1]'
          'p = Poly.from_expr(f,x)'
          'return p.all_coeffs(),' };

  c2 = python_cmd (cmd, sym(p), sym(x));
  if (isempty(c2))
    error('Empty python output, can this happen?  A bug.')
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

end


%!shared x,y,a,b,c
%! syms x y a b c
%!assert (isequal (sym2polysane (x^2 + 3*x - 4), sym([1 3 -4])))
%!assert (isequal (sym2polysane (x^6 - x^3), sym([1 0 0 -1 0 0 0])))
%!assert (isequal (sym2polysane (x^2 + 3*x - 4, x), sym([1 3 -4])))
%!assert (isequal (sym2polysane (pi*x^2 + exp(sym(1))), [sym(pi) 0 exp(sym(1))]))
%!assert (isequal (sym2polysane (poly2sym ([1 2 3])), sym([1 2 3])))
%!assert (isa (sym2polysane (x^2 + 3*x - 4), 'sym'))
%% types
%% tests with other vars
%!assert (isequal (sym2polysane (x^2+y*x, x), [sym(1) y sym(0)]))
%!assert (isequal (sym2polysane (x^2+y*x, y), [x x^2]))
%% inverse relationship
%!assert (isequal (sym2polysane (poly2sym ([a b c], x), x), [a b c]))
%!assert (isequal (poly2sym (sym2polysane(a*x^2 + c, x), x), a*x^2 + c))

%!error <more than one symbol>
%! % too many symbols for single-input
%! p = a*x^2 + 2;
%! c = sym2polysane (p);
