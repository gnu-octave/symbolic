%% Copyright (C) 2015, 2016, 2018 Colin B. Macdonald
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
%% @defmethod @@sym ipermute (@var{B}, @var{iperm})
%% Invert a permutation the indices of a symbolic array.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2 pi; 4 5 6]);
%% B = permute(A, [2 1]);
%% ipermute(B, [2 1])
%%   @result{} ans = (sym 2×3 matrix)
%%       ⎡1  2  π⎤
%%       ⎢       ⎥
%%       ⎣4  5  6⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/permute}
%% @end defmethod


function A = ipermute(B, iperm)

  if (nargin < 2)
    print_usage ();
  end

  A = permute(B, iperm);

end


%!error <Invalid> permute (sym(1))

%!test
%! syms x
%! A = [1 x];
%! perm = [2 1];
%! B = permute(A, perm);
%! C = ipermute(B, perm);
%! assert (isequal(C, A))
