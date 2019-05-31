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
%% @defmethod  @@sym symsum (@var{f}, @var{n}, @var{a}, @var{b})
%% @defmethodx @@sym symsum (@var{f}, @var{n}, [@var{a} @var{b}])
%% @defmethodx @@sym symsum (@var{f}, @var{a}, @var{b})
%% @defmethodx @@sym symsum (@var{f}, [@var{a} @var{b}])
%% @defmethodx @@sym symsum (@var{f}, @var{n})
%% @defmethodx @@sym symsum (@var{f})
%% Symbolic summation.
%%
%% The sum of the expression @var{f} for @var{n} from @var{a} to
%% @var{b}.  When @var{n} is omitted it is determined using
%% @code{symvar} and defaults to @code{x} if @var{f} is constant. The
%% limits @var{a} and @var{b} default to 0 and @var{n} - 1
%% respectively.
%%
%% @example
%% @group
%% syms n m
%% symsum(1/n^2, n, 1, m)
%%   @result{} (sym) harmonic(m, 2)
%%
%% symsum(exp(2*n)/sin(n), n, 2*m, 6*m)
%%   @result{} (sym)
%%           6⋅m
%%           ____
%%           ╲
%%            ╲      2⋅n
%%             ╲    ℯ
%%             ╱   ──────
%%            ╱    sin(n)
%%           ╱
%%           ‾‾‾‾
%%         n = 2⋅m
%% @end group
%% @end example
%%
%% @seealso{@@sym/symprod, @@sym/sum}
%% @end defmethod


function S = symsum(f, n, a, b)

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
    a = sym(0);
    b = n - 1;
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
    a = sym(0);
    b = n - 1;
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
           'S = sp.summation(f, (n, a, b))'
           'return S,' };

  S = pycall_sympy__ (cmd, sym(f), sym(n), sym(a), sym(b));

end


%!error <Invalid> symsum (sym(1), 2, 3, 4, 5)

%!test
%! % finite sums
%! syms n
%! assert (isequal (symsum(n,n,1,10), 55))
%! assert(isa(symsum(n,n,1,10), 'sym'))
%! assert (isequal (symsum(n,n,sym(1),sym(10)), 55))
%! assert (isequal (symsum(n,n,sym(1),sym(10)), 55))
%! assert (isequal (symsum(1/n,n,1,10), sym(7381)/2520))

%!test
%! % negative limits
%! syms n
%! assert (isequal (symsum(n,n,-3,3), sym(0)))
%! assert (isequal (symsum(n,n,-3,0), sym(-6)))
%! assert (isequal (symsum(n,n,-3,-1), sym(-6)))

%!test
%! % one input
%! syms n
%! f = symsum (n);
%! g = n^2/2 - n/2;
%! assert (isequal (f, g))
%! f = symsum (2*n);
%! g = n^2 - n;
%! assert (isequal (f, g))

%!test
%! % constant input
%! f = symsum (sym(2));
%! syms x
%! g = 2*x;
%! assert (isequal (f, g))

%!test
%! % two inputs
%! syms n
%! f = symsum (2*n, n);
%! g = n^2 - n;
%! assert (isequal (f, g))

%!test
%! % two inputs, second is range
%! syms n
%! f = symsum (n, [1 6]);
%! g = 21;
%! assert (isequal (f, g))
%! f = symsum (n, [sym(1) 6]);
%! g = 21;
%! assert (isequal (f, g))
%! f = symsum (2*n, [1 6]);
%! g = 2*21;
%! assert (isequal (f, g))

%!test
%! % three inputs, last is range
%! syms n
%! f = symsum (2*n, n, [1 4]);
%! g = sym(20);
%! assert (isequal (f, g))
%! f = symsum (2*n, n, [sym(1) 4]);
%! g = sym(20);
%! assert (isequal (f, g))
%! f = symsum (2, n, [sym(1) 4]);
%! g = sym(8);
%! assert (isequal (f, g))

%!test
%! % three inputs, no range
%! syms n
%! f = symsum (2*n, 1, 4);
%! g = sym(20);
%! assert (isequal (f, g))
%! f = symsum (5, sym(1), 3);
%! g = sym(15);
%! assert (isequal (f, g))

%!test
%! % ok to use double's for arguments in infinite series
%! syms n oo
%! assert(isequal(symsum(1/n^2,n,1,oo), sym(pi)^2/6))
%! assert(isequal(symsum(1/n^2,n,1,inf), sym(pi)^2/6))

%!test
%! % should be oo because 1 is real but seems to be
%! % zoo/oo depending on sympy version
%! syms n oo
%! zoo = sym('zoo');
%! assert (isequal (symsum(1/n,n,1,oo), oo) || ...
%!         isequal (symsum(1/n,n,1,oo), zoo))
