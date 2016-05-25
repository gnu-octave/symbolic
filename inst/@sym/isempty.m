%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod  @@sym isempty (@var{x})
%% Return true a symbolic array is empty (one dimension is zero).
%%
%% Examples:
%% @example
%% @group
%% isempty(sym([]))
%%   @result{} 1
%% isempty(sym(pi))
%%   @result{} 0
%% isempty(sym(zeros(4, 0)))
%%   @result{} 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/size, @@sym/numel}
%% @end defmethod

function r = isempty(x)

  if (nargin ~= 1)
    print_usage ();
  end

  d = size(x);

  % Octave can have n x 0 and 0 x m empty arrays
  % logical in case one has symbolic size
  % r = logical(prod(d) == 0);

  % safer, in case we use NaN later
  r = any(logical(d == 0));

end


%% Tests
%!shared se, a
%! se = sym ([]);
%! a = sym ([1 2]);
%!assert (~isempty (sym (1)))
%!assert (isempty (sym (se)))
%!assert (isempty (se == []))
%!test
% assert (isempty (a([])))
% assert (isempty (a([se])))

%% Growing an empty symfun into a scalar
%!test se(1) = 10;
%!test assert ( isa (se, 'sym'))
%!test assert ( isequal (se, 10))

%!shared

%!test
%! % empty matrices
%! A = sym('A', [3 0]);
%! assert (isempty (A))
%! A = sym(ones(3,0));
%! assert (isempty (A))

%!test
%! % non-empty symbolic-size matrices
%! syms n integer
%! A = sym('A', [3 n]);
%! assert (~isempty (A))

%!xtest
%! % empty symbolic-size matrices
%! % FIXME: will fail until size stop lying by saying 1x1
%! syms n integer
%! A = sym('A', [0 n]);
%! assert (isempty (A))
%! A = sym('A', [n 0]);
%! assert (isempty (A))
