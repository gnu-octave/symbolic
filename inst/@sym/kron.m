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
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{c} =} kron (@var{a}, @var{b})
%% Kronecker tensor product of two matrices .
%%
%% Examples:
%% @example
%% @group
%% >> kron(eye(2),[1,-1;-1,1])
%%		@result{}	ans =
%%
%%			 1  -1   0   0
%%			-1   1   0   0
%%			 0   0   1  -1
%%			 0   0  -1   1
%%
%% @end group
%% @end example
%
%% @example
%% @group
%% >> syms x y
%% >> kron([1,2],[x,y;y,x])
%%		@result{}	ans = (sym 2×4 matrix)
%%
%%	  		⎡x  y  2⋅x  2⋅y⎤
%%	  		⎢              ⎥
%%	  		⎣y  x  2⋅y  2⋅x⎦
%%						
%% @end group
%% @end example
%% @end deftypefn
%% Author: Utkarsh Gautam
%% Keywords:  kron product
function c = kron(a, b)

	if ~(ismatrix(a) && ismatrix(b))
		error('Invalid Input');
	end	
  cmd = { 'a, b = _ins'
  				'from sympy.physics.quantum import TensorProduct'
  				'from sympy import I, Matrix, symbols'
          'return TensorProduct(Matrix(a),Matrix(b)),'
        };

  c = python_cmd (cmd, sym(a), sym(b));

end


%!test
%! A = [1, 2; 4, 5];
%! B = ones(2);
%! expected =[1, 1, 2, 2; 1, 1, 2, 2; 4, 4, 5, 5; 4, 4, 5, 5];
%! assert (isequal(kron(A,B),expected))


%!test
%! A = [1, 2; 4,5];
%! B = 2;
%! expected= 2*[1, 2; 4, 5];
%! assert (isequal(kron(A,B),expected))

%!test
%! syms x y;
%! X = [x, x];
%! Y = [y; y];
%! expected = ones(2)*(x*y);
%! assert (isequal(kron(X,Y), expected))


%!test
%! syms x y z
%! X = [x, y, z];
%! Y = [y, y; x, x];
%! expected =[x*y, x*y, y**2, y**2, y*z, y*z; x**2, x**2, x*y, x*y, x*z, x*z];
%! assert (isequal(kron(X,Y), expected))

%!test
%! syms x y
%! X = [x, x**2; y, y**2];
%! Y = [1, 0; 0, 1];
%! expected =[x, x**2, 0, 0; y, y**2, 0, 0; 0, 0, x, x**2; 0, 0, y, y**2];
%! assert (isequal(kron(Y,X), expected))