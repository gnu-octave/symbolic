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
%% @deftypefn  {Function File}  {@var{S} =} finiteset (@var{a}, @var{b}, @dots{})
%% @deftypefnx {Function File}  {@var{S} =} finiteset (@var{cellarray})
%% @deftypefnx {Function File}  {@var{e} =} finiteset ()
%% Return a set containing the inputs without duplicates.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% S = finiteset(1, pi, x, 1, 1, x, x + y)
%%   @result{} S = (sym) @{1, π, x, x + y@}
%% subs(S, x, pi)
%%   @result{} ans = (sym) @{1, π, y + π@}
%% @end group
%% @end example
%%
%% You can also use this to make the empty set:
%% @example
%% @group
%% finiteset()
%%   @result{} ans = (sym) ∅
%% @end group
%% @end example
%%
%% You cannot directly access elements of a set using indexing:
%% @example
%% @group
%% S(2)
%%   @print{} ??? ind2sub: index out of range
%% @end group
%% @end example
%% Instead you can first convert it to a cell (@pxref{@@sym/children}):
%% @example
%% @group
%% elements = children(S)
%%   @result{} elements = (sym) [1  π  x  x + y]  (1×4 matrix)
%% elements(end)
%%   @result{} ans = (sym) x + y
%% @end group
%% @end example
%%
%% Careful, passing a matrix created a set of matrices (rather than a
%% set from the elements of the matrix):
%% @example
%% @group
%% finiteset([1 x 1 1])
%%   @result{} ans = (sym) @{[1  x  1  1]@}
%% finiteset([1 pi], [1 x 1 1], [1 pi])
%%   @result{} ans = (sym) @{[1  π], [1  x  1  1]@}
%% @end group
%% @end example
%%
%% On the other hand, if you @emph{want} to make a set from the
%% elements of a matrix, first convert it to a cell array:
%% @example
%% @group
%% A = [1 x 1; 2 1 x];
%% finiteset(num2cell(A))
%%   @result{} ans = (sym) @{1, 2, x@}
%% @end group
%% @end example
%%
%% Sets can be nested:
%% @example
%% @group
%% finiteset(finiteset(), finiteset(finiteset()))
%%   @result{} (sym) @{∅, @{∅@}@}
%% @end group
%% @end example
%%
%% @strong{Note} that cell arrays are @emph{not} the same thing as
%% sets (despite the similar rendering using @code{@{} and @code{@}}).
%% For example, this creates a set containing a set:
%% @example
%% @group
%% finiteset(finiteset(1, 2, 3, 3))
%%   @result{} ans = (sym) @{@{1, 2, 3@}@}
%% @end group
%% @end example
%% whereas passing a single cell array @var{cellarray} creates a set
%% containing each element of @var{cellarray}:
%% @example
%% @group
%% finiteset(@{1, 2, 3, 3@})
%%   @result{} ans = (sym) @{1, 2, 3@}
%% @end group
%% @end example
%% (This is implemented mainly to enable the @code{num2cell} example
%% above.)
%%
%% @seealso{interval, ismember, children, union, intersect, setdiff, setxor}
%% @end deftypefn

function S = finiteset(varargin)

  if (nargin == 1 && iscell(varargin{1}))
    varargin = sym(varargin{1});
  else
    varargin = sym(varargin);
  end

  S = python_cmd ('return FiniteSet(*_ins),', varargin{:});

end


%!test
%! s1 = finiteset(sym(1), 2, 2);
%! s2 = finiteset(sym(1), 2, 2, 2);
%! assert (isequal (s1, s2))

%!test
%! s1 = finiteset(sym(0), 1);
%! s2 = finiteset(sym(0), 2, 3);
%! s = finiteset(sym(0), 1, 2, 3);
%! assert (isequal (s1 + s2, s))

%!test
%! e = finiteset();
%! s = finiteset(sym(1));
%! s2 = e + s;
%! assert (isequal (s, s2))
