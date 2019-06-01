%% Copyright (C) 2016 Lagu
%% Copyright (C) 2019 Colin B. Macdonald
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
%% @defmethod @@sym hilb (@var{n})
%% Return the symbolic Hilbert matrix.
%%
%% Example:
%% @example
%% @group
%% hilb (sym(2))
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡ 1   1/2⎤
%%       ⎢        ⎥
%%       ⎣1/2  1/3⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/invhilb}
%% @end defmethod


function y = hilb(x)
  if (nargin ~= 1)
    print_usage ();
  end

  y = pycall_sympy__ ('return Matrix(_ins[0], _ins[0], lambda i,j: 1 / (i + j + 1)),', x);

end


%!test
%! A = hilb (sym(3));
%! B = [sym(1) sym(1)/2 sym(1)/3; sym(1)/2 sym(1)/3 sym(1)/4; sym(1)/3 sym(1)/4 sym(1)/5];
%! assert (isequal (A, B))
