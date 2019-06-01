%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym symprod (@var{f}, @var{n}, @var{a}, @var{b})
%% @defmethodx @@sym symprod (@var{f}, @var{n}, [@var{a} @var{b}])
%% @defmethodx @@sym symprod (@var{f}, @var{a}, @var{b})
%% @defmethodx @@sym symprod (@var{f}, [@var{a} @var{b}])
%% @defmethodx @@sym symprod (@var{f}, @var{n})
%% @defmethodx @@sym symprod (@var{f})
%% Symbolic product.
%%
%% The product of the expression @var{f} as variable @var{n} changes
%% from @var{a} to @var{b}.  When @var{n} is omitted it is determined
%% using @code{symvar} and defaults to @code{x} if @var{f} is
%% constant. The limits @var{a} and @var{b} default to @code{1} and
%% @var{n} respectively.
%%
%% Examples:
%% @example
%% @group
%% syms n m x
%% symprod(sin(n*x), n, [1 3])
%%   @result{} (sym) sin(x)⋅sin(2⋅x)⋅sin(3⋅x)
%% symprod(n, n, 1, m)
%%   @result{} (sym) m!
%% @end group
%% @end example
%%
%% Unevaluated product:
%% @example
%% @group
%% syms x m
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% symprod(sin(x), x, [1 m])
%%   @result{} (sym)
%%         m
%%       ─┬─┬─
%%        │ │ sin(x)
%%        │ │
%%       x = 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/symsum, @@sym/prod}
%% @end defmethod


function S = symprod(f, n, a, b)

  if (nargin > 4)
    print_usage ();
  end

  idx1.type = '()';
  idx1.subs = {1};
  idx2.type = '()';
  idx2.subs = {2};

  if (nargin == 1)
    n = symvar(f, 1);
    if (isempty(n))
      n = sym('x');
    end
    a = sym(1);
    b = n;
  elseif (nargin == 2) && (length(n) == 2)
    f = sym(f);
    %a = n(1);  % issue #17
    %b = n(2);
    a = subsref(n, idx1);
    b = subsref(n, idx2);
    n = symvar(f, 1);
    if (isempty(n))
      n = sym('x');
    end
  elseif (nargin == 2)
    f = sym(f);
    n = sym(n);
    a = sym(1);
    b = n;
  elseif (nargin == 3) && (length(a) == 2)
    f = sym(f);
    n = sym(n);
    %b = a(2);  % issue #17
    %a = a(1);
    b = subsref(a, idx2);
    a = subsref(a, idx1);
  elseif (nargin == 3)
    f = sym(f);
    b = a;
    a = n;
    n = symvar(f, 1);
    if (isempty(n))
      n = sym('x');
    end
  else
    f = sym(f);
    n = sym(n);
    a = sym(a);
    b = sym(b);
  end

  cmd = { '(f, n, a, b) = _ins'
          'S = sp.product(f, (n, a, b))'
          'return S,' };

  S = pycall_sympy__ (cmd, sym(f), sym(n), sym(a), sym(b));

end


%!error <Invalid> symprod (sym(1), 2, 3, 4, 5)

%!test
%! % simple
%! syms n
%! assert (isequal (symprod(n, n, 1, 10), factorial(sym(10))))
%! assert (isequal (symprod(n, n, sym(1), sym(10)), factorial(10)))

%!test
%! % one input
%! syms n
%! f = symprod (n);
%! g = factorial (n);
%! assert (isequal (f, g))
%! f = symprod (2*n);
%! g = 2^n * factorial (n);
%! assert (isequal (f, g))

%!test
%! % constant input
%! f = symprod (sym(2));
%! syms x
%! g = 2^x;
%! assert (isequal (f, g))

%!test
%! % two inputs
%! syms n
%! f = symprod (2*n, n);
%! g = 2^n * factorial (n);
%! assert (isequal (f, g))

%!test
%! % two inputs, second is range
%! syms n
%! f = symprod (n, [1 6]);
%! g = 720;
%! assert (isequal (f, g))
%! f = symprod (n, [sym(1) 6]);
%! g = 720;
%! assert (isequal (f, g))
%! f = symprod (2*n, [1 6]);
%! g = sym(2)^6*720;
%! assert (isequal (f, g))

%!test
%! % three inputs, last is range
%! syms n
%! f = symprod (2*n, n, [1 4]);
%! g = sym(384);
%! assert (isequal (f, g))
%! f = symprod (2*n, n, [sym(1) 4]);
%! g = sym(384);
%! assert (isequal (f, g))
%! f = symprod (2, n, [sym(1) 4]);
%! g = sym(16);
%! assert (isequal (f, g))

%!test
%! % three inputs, no range
%! syms n
%! f = symprod (2*n, 1, 4);
%! g = sym(384);
%! assert (isequal (f, g))
%! f = symprod (5, sym(1), 3);
%! g = sym(125);
%! assert (isequal (f, g))

%!test
%! % infinite product
%! syms a n oo
%! zoo = sym('zoo');
%! assert (isequal (symprod(a, n, 1, oo), a^oo))
%! assert (isequal (symprod(a, n, 1, inf), a^oo))

%%!test
%%! % FIXME: commented out test...
%%! % SymPy 0.7.6: nan
%%! % SymPy git: interesting that 1**oo is nan but this is still 1
%%! assert (isequal (symprod(1, n, 1, oo), sym(1)))
