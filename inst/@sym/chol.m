%% Copyright (C) 2016 Lagu
%% Copyright (C) 2017-2019 Colin B. Macdonald
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
%% @deftypemethod @@sym {@var{L} =} chol (@var{A})
%% Cholesky factorization of symbolic symmetric matrix.
%%
%% Returns a lower-triangular matrix @var{L}, such that @code{L*L'}
%% is matrix @var{A}.  The matrix @var{A} must be symmetric
%% positive-definite.  Example:
%% @example
%% @group
%% A = sym([1 2 4; 2 13 23; 4 23 43])
%%   @result{} A = (sym 3×3 matrix)
%%
%%       ⎡1  2   4 ⎤
%%       ⎢         ⎥
%%       ⎢2  13  23⎥
%%       ⎢         ⎥
%%       ⎣4  23  43⎦
%%
%% L = chol(A)
%%   @result{} L = (sym 3×3 matrix)
%%
%%       ⎡1  0  0 ⎤
%%       ⎢        ⎥
%%       ⎢2  3  0 ⎥
%%       ⎢        ⎥
%%       ⎣4  5  √2⎦
%%
%% L*L'
%%   @result{} (sym 3×3 matrix)
%%
%%       ⎡1  2   4 ⎤
%%       ⎢         ⎥
%%       ⎢2  13  23⎥
%%       ⎢         ⎥
%%       ⎣4  23  43⎦
%% @end group
%% @end example
%%
%% @seealso{chol, @@sym/qr, @@sym/lu}
%% @end deftypemethod


function y = chol(x)
  if (nargin == 2)
    error('Operation not supported yet.');
  elseif (nargin > 2)
    print_usage ();
  end
  y = pycall_sympy__ ('return _ins[0].cholesky(),', x);
end


%!error <must be> chol (sym ([1 2; 3 4]));
%!error <must be square> chol (sym ([1 2; 3 4; 5 6]));

%!test
%! A = chol(hilb(sym(2)));
%! B = [[1 0]; sym(1)/2 sqrt(sym(3))/6];
%! assert( isequal( A, B ))
