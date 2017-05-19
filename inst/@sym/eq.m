%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defop  Method   @@sym eq {(@var{a}, @var{b})}
%% @defopx Operator @@sym {@var{a} == @var{b}} {}
%% Test for symbolic equality, and/or define equation.
%%
%% The code @code{@var{a} == @var{b}} can do one of two things:
%% @itemize
%% @item Return a symbolic boolean value if it can quickly determine
%% that @code{a} and @code{b} are the same or not:
%% @example
%% @group
%% sym(1) == sym(pi)
%%   @result{} (sym) False
%% @end group
%% @end example
%% @item Otherwise, return a symbolic equation:
%% @example
%% @group
%% syms x y
%% 3*y == 24*x
%%   @result{} ans = (sym) 3⋅y = 24⋅x
%% solve(ans, y)
%%   @result{} (sym) 8⋅x
%% @end group
%% @end example
%% @end itemize
%%
%% Exactly which behaviour happens is a potential source of bugs!
%% When @var{a} and/or @var{b} contain variables, we @emph{usually}
%% (but not always) expect a symbolic equation.  Compare:
%% @example
%% @group
%% x == 3*x
%%   @result{} (sym) x = 3⋅x
%% x == x
%%   @result{} (sym) True
%% @end group
%% @end example
%%
%% If you wish to force a boolean result, @pxref{@@sym/logical} and @pxref{@@sym/isAlways}:
%% @example
%% @group
%% logical(x == 3*x)
%%   @result{} 0
%% islogical(ans)
%%   @result{} 1
%% @end group
%%
%% @group
%% syms x y z
%% eqn = x*(y + z) == x*y + x*z
%%   @result{} eqn = (sym) x⋅(y + z) = x⋅y + x⋅z
%% logical(eqn)
%%   @result{} 0
%% isAlways(eqn)
%%   @result{} 1
%% @end group
%% @end example
%%
%% Currently, these is no robust way to force an an equality equation
%% @code{x == x}.
%%
%% @seealso{@@sym/logical, @@sym/isAlways, @@sym/isequal, @@sym/ne, @@sym/le}
%% @end defop

function t = eq(x, y)

  if (nargin ~= 2)
    print_usage ();
  end

  t = ineq_helper('[donotuse]', 'Eq', sym(x), sym(y));

end


%!test
%! % simple tests with scalar numbers
%! assert (logical (sym(1) == sym(1)))
%! assert (logical (sym(1) == 1))
%! assert (~logical (sym(1) == 0))
%! assert (isequal (sym(1) == sym(1), sym(true)))
%! assert (isequal (sym(1) == 1, sym(true)))
%! assert (isequal (sym(1) == 0, sym(false)))

%!test
%! % Type of the output is sym or logical?
%! % FIXME: in current version, they are sym
%! e = sym(1) == sym(1);
%! %assert (islogical (e))
%! assert (isa (e, 'sym'))

%!test
%! % things involving a variable are usually not bool but sym.
%! % (SMT behaviour says always, FIXME: currently we differ.)
%! syms x
%! e = x == 0;
%! assert (~islogical (e))
%! assert (isa (e, 'sym'))

%!test
%! % ... except of course via cancelation
%! syms x
%! e = x - x == 0;
%! assert (logical (e))
%! assert (isequal (e, sym(true)))

%!test
%! % array == array
%! a = sym([1 2; 3 4]);
%! y = a == a;
%! assert (isequal( size(y), [2 2]))
%! assert (isequal (y, sym([true true; true true])))
%! assert (all(all(y)))
%! y = a == 1;
%! assert (isequal( size(y), [2 2]))
%! assert (isequal (y, sym([true false; false false])))
%! assert (any(any(y)))
%! y = a == 42;
%! assert (isequal( size(y), [2 2]))
%! assert (isequal (y, sym([false false; false false])))

%!test
%! % more array == array
%! D = [0 1; 2 3];
%! A = [sym(0) 1; sym(2) 3];
%! DZ = D - D;
%! assert (isequal (logical(A == A), [true true; true true]))
%! assert (isequal (logical(A == D), [true true; true true]))
%! assert (isequal (logical(A - D == DZ), [true true; true true]))
%! assert (all (all (  A == A  )))
%! assert (all (all (  A == D  )))
%! assert (all (all (  A - D == DZ  )))

%!test
%! % logical output, right shape, etc
%! t = true; f = false;
%! a = sym([0 1 2; 3 4 5]);
%! b = sym([0 1 1; 3 5 5]);
%! e = a == b;
%! eexp = sym(logical([1 1 0; 1 0 1]));
%! assert (isequal (e, eexp))
%! a = sym([0 1 2]);
%! b = sym([0 1 1]);
%! e = a == b;
%! eexp = sym(logical([1 1 0]));
%! assert (isequal (e, eexp))
%! e = a' == b';
%! eexp = eexp.';  % is/was bug here with '
%! assert (isequal (e, eexp))

%!test
%! % empty matrices compare to correct empty size
%! a = zeros (sym(3), 0);
%! assert (size (a == a), [3, 0])
%! a = zeros (sym(0), 2);
%! assert (size (a == a), [0, 2])
