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
%% @deftypemethod  @@sym {@var{d} =} size (@var{x})
%% @deftypemethodx @@sym {[@var{n}, @var{m}] =} size (@var{x})
%% @deftypemethodx @@sym {@var{d} =} size (@var{x}, @var{dim})
%% Return the size of a symbolic array.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% A = [1 2 x; x 3 4];
%% [n, m] = size(A)
%%   @result{} n = 2
%%   @result{} m = 3
%% @end group
%%
%% @group
%% A = sym('a', [3 4]);
%% [n, m] = size(A)
%%   @result{} n = 3
%%   @result{} m = 4
%% size(A, 1)
%%   @result{} 3
%% size(A, 2)
%%   @result{} 4
%% @end group
%% @end example
%%
%% Symbolic-sized matrices currently return @code{1 × 1} but we might
%% prefer @code{NaN × NaN}:
%% @example
%% @group
%% syms n m integer
%% A = sym('a', [n m])
%%   @result{} A = (sym) a  (n×m matrix expression)
%%
%% size(A)          % doctest: +XFAIL
%%   @result{} NaN   NaN
%% @end group
%% @end example
%%
%% @seealso{@@sym/length, @@sym/numel}
%% @end deftypemethod

function [n, m] = size(x, dim)

  % Note: symbolic sized matrices should return double, not sym/string.

  n = x.size;

  % FIXME: for now, we artificially force symbolic sized objects
  % (where one or more dimension is recorded as NaN) to be 1x1.
  % This effects MatrixSymbol and MatrixExpr.  See Issue #159.
  if (any(isnan(n)))
    n = [1 1];
  end
  % Alternatively:
  %n(isnan(n)) = 1;

  if (nargin == 2) && (nargout == 2)
    print_usage ();
  elseif (nargout == 2)
    m = n(2);
    n = n(1);
  elseif (nargin == 2)
    n = n(dim);
  end

end


%!test
%! a = sym([1 2 3]);
%! [n,m] = size(a);
%! assert (n == 1 && m == 3)

%!test
%! a = sym([1 2 3]);
%! n = size(a);
%! assert (isequal (n, [1 3]))

%!test
%! %% size, numel, length
%! a = sym([1 2 3; 4 5 6]);
%! assert (isa (size(a), 'double'))
%! assert (isa (numel(a), 'double'))
%! assert (isa (length(a), 'double'))
%! assert (isequal (size(a), [2 3]))
%! assert (length(a) == 3)
%! assert (numel(a) == 6)
%! a = sym([1; 2; 3]);
%! assert (isequal (size(a), [3 1]))
%! assert (length(a) == 3)
%! assert (numel(a) == 3)

%!test
%! %% size by dim
%! a = sym([1 2 3; 4 5 6]);
%! n = size(a, 1);
%! assert (n == 2)
%! m = size(a, 2);
%! assert (m == 3)
%! a = sym([1 2 3]');
%! n = size(a, 1);
%! assert (n == 3)
%! m = size(a, 2);
%! assert (m == 1)

%!xtest
%! % symbolic-size matrices
%! syms n m integer
%! A = sym('A', [n m]);
%! d = size(A);
%! assert (~isa(d, 'sym'))
%! assert (isnumeric(d))
%! assert (isequaln (d, [NaN NaN]))

%!xtest
%! % half-symbolic-size matrices
%! % FIXME: will fail until size stop lying by saying 1x1
%! syms n integer
%! A = sym('A', [n 3]);
%! assert (isequaln (size(A), [NaN 3]))
%! A = sym('A', [4 n]);
%! assert (isequaln (size(A), [4 NaN]))

%!xtest
%! % half-symbolic-size empty matrices
%! % FIXME: will fail until size stop lying by saying 1x1
%! syms n integer
%! A = sym('A', [n 0]);
%! assert (isequaln (size(A), [NaN 0]))
