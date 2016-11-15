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
%% @defmethod @@sym invhilb (@var{n})
%% Return the symbolic inverse of the Hilbert matrix.
%%
%% Example:
%% @example
%% @group
%% invhilb (sym(2))
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡4   -6⎤
%%       ⎢      ⎥
%%       ⎣-6  12⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/hilb}
%% @end defmethod


function y = invhilb(x)
  if (nargin ~= 1)
    print_usage ();
  end

  y = inv(hilb(x));

end


%!test
%! A = invhilb(sym(3));
%! B = sym([9 -36 30;-36 192 -180;30 -180 180]);
%! assert( isequal( A, B))
