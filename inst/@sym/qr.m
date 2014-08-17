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
%% @deftypefn  {Function File} {@var{q}, @var{r} =} qr (@var{a})
%% Symbolic QR factorization of a matrix.
%%
%% FIXME: The sympy QR routine could probably be improved. 
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [Q, R] = qr(A, ord)

  if (nargin == 2)
    warning('economy-size not implemented')
  end

  cmd = [ '(A,) = _ins\n'  ...
          'if not A.is_Matrix:\n' ...
          '    A = sp.Matrix([A])\n' ...
          '(Q, R) = A.QRdecomposition()\n' ...
          'return (Q, R)' ];

  [Q, R] = python_cmd (cmd, sym(A));

end


%!test
%! % scalar
%! [q, r] = qr(sym(6));
%! assert (isequal (q, sym(1)))
%! assert (isequal (r, sym(6)))
%! syms x
%! [q, r] = qr(x);
%! assert (isequal (q*r, x))
%! % could hardcode this if desired
%! %assert (isequal (q, sym(1)))
%! %assert (isequal (r, x))

%!test
%! A = [1 2; 3 4];
%! B = sym(A);
%! [Q, R] = qr(B);
%! assert (isequal (Q*R, B))
%! assert (isequal (R(2,1), sym(0)))
%! assert (isequal (Q(:,1)'*Q(:,2), sym(0)))
%! %[QA, RA] = qr(A)
%! %assert ( max(max(double(Q)-QA)) <= 10*eps)
%! %assert ( max(max(double(Q)-QA)) <= 10*eps)

%%!xtest
%%! % non square matrix
%%! assert (false)


