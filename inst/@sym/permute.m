%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{B} =} permute (@var{A}, @var{perm})
%% Permute the indices of a symbolic array.
%%
%% Generalizes transpose, but currently doesn't do much as we only
%% support 2D symbolic arrays.
%%
%% @seealso{ipermute}
%% @end deftypefn

function B = permute(A, perm)

  if (isequal(perm, [1 2]))
    B = A;
  elseif  (isequal(perm, [2 1]))
    B = A.';
  else
    print_usage ();
  end

end


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
