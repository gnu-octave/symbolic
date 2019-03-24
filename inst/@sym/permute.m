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
%% @defmethod @@sym permute (@var{A}, @var{perm})
%% Permute the indices of a symbolic array.
%%
%% Generalizes transpose, but currently doesn't do much as we only
%% support 2D symbolic arrays.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2 pi; 4 5 6]);
%% B = permute(A, [2 1])
%%   @result{} B = (sym 3×2 matrix)
%%       ⎡1  4⎤
%%       ⎢    ⎥
%%       ⎢2  5⎥
%%       ⎢    ⎥
%%       ⎣π  6⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/ipermute}
%% @end defmethod


function B = permute(A, perm)

  if (nargin < 2)
    print_usage ();
  end

  if (isequal(perm, [1 2]))
    B = A;
  elseif  (isequal(perm, [2 1]))
    B = A.';
  else
    print_usage ();
  end

end


%!error <Invalid> permute (sym(1))

%!test
%! D = round(10*rand(5,3));
%! A = sym(D);
%! B = permute(A, [1 2]);
%! assert (isequal(B, A))
%! B = permute(A, [2 1]);
%! assert (isequal(B, A.'))

%!test
%! syms x
%! A = [1 x];
%! B = permute(A, [2 1]);
%! assert (isequal(B, [1; x]))
