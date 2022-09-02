%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
%% Copyright (C) 2022 Alex Vong
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
%% @defmethod  @@sym repmat (@var{A}, @var{n}, @var{m})
%% @defmethodx @@sym repmat (@var{A}, [@var{n} @var{m}])
%% Build symbolic block matrices.
%%
%% Examples:
%% @example
%% @group
%% repmat([1 2 sym(pi)], 2, 3)
%%   @result{} (sym 2×9 matrix)
%%       ⎡1  2  π  1  2  π  1  2  π⎤
%%       ⎢                         ⎥
%%       ⎣1  2  π  1  2  π  1  2  π⎦
%%
%% repmat(sym(pi), [1 3])
%%   @result{} (sym) [π  π  π]  (1×3 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/vertcat, @@sym/horzcat}
%% @end defmethod


function B = repmat(A, n, m)

  if (nargin == 2)
    m = n(2);
    n = n(1);
  elseif (nargin == 3)
    % no-op
  else
    print_usage ();
  end

  if n == 0 || m == 0
    [nrows_A, ncols_A] = size (A);
    B = sym (zeros (n * nrows_A, m * ncols_A));
    return
  end

  %% duplicate A horizontally m times
  MM = cellfun (@(varargin) A, cell (1, m), 'UniformOutput', false);
  M = horzcat (MM{:});

  %% now duplicate that result vertically n times
  NN = cellfun (@(varargin) M, cell (1, n), 'UniformOutput', false);
  N = vertcat (NN{:});

  B = N;

end


%!test
%! % simple
%! syms x
%! A = [x x x; x x x];
%! assert (isequal (repmat(x, 2, 3), A))

%!test
%! % block cf double
%! A = [1 2 3; 4 5 6];
%! B = sym(A);
%! C = repmat(A, 2, 3);
%! D = repmat(B, 2, 3);
%! assert (isequal (C, D))

%!test
%! % empty
%! A = repmat(sym([]), 2, 3);
%! assert (isempty(A));
%! assert (isequal (size(A), [0 0]))

%!test
%! % more empties
%! A = repmat(sym(pi), [0 0]);
%! assert (isequal (size(A), [0 0]))
%! A = repmat(sym(pi), [0 3]);
%! assert (isequal (size(A), [0 3]))
%! A = repmat(sym(pi), [2 0]);
%! assert (isequal (size(A), [2 0]))

%!test
%! % even more empties, see also https://github.com/cbm755/octsympy/issues/1218
%! A = randi (16, 5, 7);
%! assert (isa (repmat (sym (A), [0 3]), 'sym'));
%! assert (isa (repmat (sym (A), [2 0]), 'sym'));
%! assert (isequal (sym (repmat (A, [0 3])), (repmat (sym (A), [0 3]))));
%! assert (isequal (sym (repmat (A, [2 0])), (repmat (sym (A), [2 0]))));
