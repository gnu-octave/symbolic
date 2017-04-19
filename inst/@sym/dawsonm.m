%% Copyright (C) 2016 Lagu
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
%% @defmethod @@sym dawsonm (@var{x})
%% Compute the Dawson (scaled imaginary error) function in a matrix.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 1; 0 1]);
%% dawsonm (A)
%%   @result{} ans = (sym 2×2 matrix)
%%     ⎡ℯ⋅√π⋅erfi(1)  3⋅ℯ⋅√π⋅erfi(1)⎤
%%     ⎢────────────  ──────────────⎥
%%     ⎢     2              2       ⎥
%%     ⎢                            ⎥
%%     ⎢               ℯ⋅√π⋅erfi(1) ⎥
%%     ⎢     0         ──────────── ⎥
%%     ⎣                    2       ⎦
%% @end group
%% @end example
%% @seealso{@@sym/dawson, @@sym/erfc, @@sym/erf, @@sym/erfcx, @@sym/erfi, @@sym/erfinv, @@sym/erfcinv}
%% @end defmethod


function y = dawsonm(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = expm(x^2)*erfi(x)*(sqrt(sym('pi'))/2);
end

%!test
%! M = [0 1; 1 0];
%! A = expm(M^2)*erfi(M)*(sqrt(pi)/2);
%! B = double(dawsonm(sym(M)));
%! assert(A, B, -eps*1.0062) %% Octave diverge in that proportion of error.
