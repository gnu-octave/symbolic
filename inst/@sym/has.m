%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod  @@sym has (@var{expr}, @var{subexpr})
%% @defmethodx @@sym has (@var{M}, @var{subexpr})
%% Naively test if an expression contains a subexpression.
%%
%% Example:
%% @example
%% @group
%% syms x
%% has(x^2 + 3*x + 2, x^2)
%%   @result{} ans =  1
%% has((x+1)*(x+2), x^2)
%%   @result{} ans =  0
%% @end group
%% @end example
%% (Note @code{has} does not try to do any mathematics: it
%% just checks whether @var{expr} @emph{as written} contains
%% @var{subexpr}.)
%%
%% If the first argument is a matrix @var{M}, check if each element
%% of the matrix contains @var{subexpr}:
%% @example
%% @group
%% M = [sym(1) sym(pi)/2; 2*sym(pi) 4];
%% has(M, sym(pi))
%%   @result{} ans =
%%       0   1
%%       1   0
%% @end group
%% @end example
%%
%% @strong{Caution:} @code{has} does not do mathematics; it is just
%% searching for @var{subexpr}.  This can lead to confusing results,
%% for example, @code{has} should not be used to check for for membership
%% in a set:
%% @example
%% @group
%% A = finiteset(1, 2, -sym(pi));
%% has(A, -1)
%%   @result{} ans =  1
%% @end group
%% @end example
%% Instead, @pxref{@@sym/ismember}.
%%
%% @seealso{@@sym/ismember}
%% @end defmethod


function r = has(f, x)

  if (nargin ~= 2)
    print_usage ();
  end

  r = uniop_bool_helper(sym(f), 'lambda f,x: f.has(x)', [], sym(x));

end


%!shared A, x, y
%! syms x y
%! A = [sym(pi) 2*sym(pi); x*y x+y];

%!assert (isequal (has(A, x), [false false; true true]));
%!assert (isequal (has(A, x+y), [false false; false true]));
%!assert (isequal (has(A, 2), [false true; false false]));
%!assert (isequal (has(A, sym(pi)), [true true; false false]));
