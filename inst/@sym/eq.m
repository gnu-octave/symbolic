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
%% @deftypefn {Function File} {@var{g} =} eq (@var{a}, @var{b})
%% Test for symbolic equality, and/or define equation.
%%
%% @code{a == b} tries to convert both @code{a} and @code{b} to
%% numbers and compare them as doubles.  If this fails, it defines
%% a symbolic expression for @code{a == b}.  When each happens is a
%% potential source of bugs!
%%
%% FIXME: Notes from SMT:
%% @itemize
%% @item If any varibles appear in the matrix, then you get a matrix
%%   of equalities:  syms x; a = sym([1 2; 3 x]); a == 1
%% @item @code{x==x} is an equality, rather than @code{true}.
%%   We currently satisfy neither of these (FIXME).
%% @end itemize
%%
%% FIXME: from reading SymPy's @code{Eq??}, the following would
%% seem to work:
%%    @code{>>> e = relational.Relational.__new__(relational.Eq, x, x)}
%% (but passing this to solve() is still different from SMT).
%%
%% FIXME: array case is hardcoded only to check for equality (see logical()).
%%   to get the SMT, could do two passes through the array.
%%
%% @seealso{logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function t = eq(x,y)

  t = ineq_helper('[donotuse]', 'Eq', x, y);

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
