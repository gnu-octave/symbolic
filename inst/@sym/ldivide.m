%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {@var{z} =} ldivide (@var{x}, @var{y})
%% Elementwise backslash of sym expressions (dot backslash).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = ldivide(x, y)

  z = rdivide(y, x);

end


%!test
%! % scalar
%! syms x
%! assert (isa (x .\ 1, 'sym'))
%! assert (isa (x .\ x, 'sym'))
%! assert (isequal (x .\ 1, 1/x))
%! assert (isequal (x .\ x, sym(1)))

%!test
%! % matrix-scalar
%! D = [1 1; 2 3];
%! A = sym(D);
%! assert (isequal ( A .\ 6 , D .\ 6  ))
%! assert (isequal ( A .\ sym(6) , D .\ 6  ))
%! assert (isequal ( D .\ sym(6) , D .\ 6  ))

%!test
%! % matrix-matrix
%! D = [1 2; 3 4];
%! A = sym(D);
%! assert (isequal ( A .\ A , D .\ D  ))
%! assert (isequal ( A .\ D , D .\ D  ))
%! assert (isequal ( D .\ A , D .\ D  ))

%!test
%! % matrix .\ matrix with symbols
%! syms x y
%! A = [x y; x^2 2*y];
%! B = [y x; x y];
%! assert (isequal ( A .\ A , sym(ones(2, 2)) ))
%! assert (isequal ( B .\ A , [x/y y/x; x 2] ))

%!test
%! % scalar .\ matrix
%! D = 3*[1 2; 3 4];
%! A = sym(D);
%! assert (isequal ( 3 .\ A , 3 .\ D  ))
