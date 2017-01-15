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
%% @defmethod @@sym isinf (@var{x})
%% Return true if a symbolic expression is infinite.
%%
%% Example:
%% @example
%% @group
%% syms x finite
%% A = [sym(inf) sym(1)/0 1; x 1 sym(inf)]
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡∞  zoo  1⎤
%%       ⎢         ⎥
%%       ⎣x   1   ∞⎦
%% isinf(A)
%%   @result{} ans =
%%       1   1   0
%%       0   0   1
%% @end group
%% @end example
%%
%% Note that the return is of type logical and thus either true or false.
%% However, the underlying SymPy software supports @code{True/False/None}
%% answers, where @code{None} indicates an unknown or indeterminate result.
%% Consider the example:
%% @example
%% @group
%% syms x
%% isinf(x)
%%   @result{} ans = 0
%% @end group
%% @end example
%% Here SymPy would have said @code{None} as it does not know whether
%% x is finite or not.  However, currently @code{isinf} returns
%% false, which perhaps should be interpreted as ``x cannot be shown to
%% be infinite'' (as opposed to ``x is not infinite'').
%%
%% FIXME: this is behaviour might change in a future version; come
%% discuss at @url{https://github.com/cbm755/octsympy/issues/308}.
%%
%% @seealso{@@sym/isnan, @@sym/double}
%% @end defmethod


function r = isinf(x)

  if (nargin ~= 1)
    print_usage ();
  end

  r = uniop_bool_helper(x, 'lambda a: a.is_infinite');

end


%!shared x,zoo,oo,snan
%! oo = sym(inf);
%! zoo = sym('zoo');
%! x = sym('x');
%! snan = sym(nan);

%!test
%! % various ops that give inf and nan
%! assert (isinf(oo))
%! assert (isinf(zoo))
%! assert (isinf(oo+oo))
%! assert (~isinf(oo+zoo))
%! assert (~isinf(0*oo))
%! assert (~isinf(0*zoo))
%! assert (~isinf(snan))
%! assert (~isinf(oo-oo))
%! assert (~isinf(oo-zoo))

%!test
%! % arrays
%! assert (isequal(  isinf([oo zoo]), [1 1]  ))
%! assert (isequal(  isinf([oo 1]),   [1 0]  ))
%! assert (isequal(  isinf([10 zoo]), [0 1]  ))
%! assert (isequal(  isinf([x oo x]), [0 1 0]  ))

%!test
%! % Must not contain string 'symbol'; these all should make an
%! % actual infinity.  Actually a ctor test, not isinf.
%! % IIRC, SMT in Matlab 2013b fails.
%! oo = sym(inf);
%! assert (isempty (strfind (sympy (oo), 'Symbol')))
%! oo = sym(-inf);
%! assert (isempty (strfind (sympy (oo), 'Symbol')))
%! oo = sym('inf');
%! assert (isempty (strfind (sympy (oo), 'Symbol')))
%! oo = sym('-inf');
%! assert (isempty (strfind (sympy (oo), 'Symbol')))
%! oo = sym('Inf');
%! assert (isempty (strfind (sympy (oo), 'Symbol')))

%!test
%! % ops with infinity shouldn't collapse
%! syms x oo zoo
%! y = x + oo;
%! assert (~isempty (strfind (lower (sympy (y)), 'add') ))
%! y = x - oo;
%! assert (~isempty (strfind (lower (sympy (y)), 'add') ))
%! y = x - zoo;
%! assert (~isempty (strfind (lower (sympy (y)), 'add') ))
%! y = x*oo;
%! assert (~isempty (strfind (lower (sympy (y)), 'mul') ))

%!test
%! % ops with infinity are not necessarily infinite
%! syms x oo zoo
%! y = x + oo;
%! assert(~isinf(y))  %  SMT 2014a says "true", I disagree
%! y = x - zoo;
%! assert(~isinf(y))
%! y = x*oo;
%! assert(~isinf(y))
