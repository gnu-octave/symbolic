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
%% @deftypefn  {Function File} {@var{B} =} inv (@var{A})
%% Symbolic inverse of a matrix.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = inv(x)

  [n,m] = size(x);
  if n ~= m
    error('matrix is not square')
  end

  cmd = {
	'x, = _ins'
	'flag = 0'
	'r = "whatev"'
	''
	'if x.is_Matrix:'
	'	try:'
	'		r = x.inv()'
	'	except ValueError:'
	'		flag = 1'
	'else:'
	'		r = S.One/x'
	''
	'return (flag, r)'};

  [flag, z] = python_cmd (cmd, x);

  if (flag)
    error('Matrix det == 0; not invertible.')
  end

end


%!test
%! % scalar
%! syms x
%! assert (isequal (inv(x), 1/x))

%!test
%! % diagonal
%! syms x
%! A = [sym(1) 0; 0 x];
%! B = [sym(1) 0; 0 1/x];
%! assert (isequal (inv(A), B))

%!test
%! % 2x2 inverse
%! A = [1 2; 3 4];
%! assert (max (max (abs (double (inv (sym (A))) - inv(A)))) <= 3*eps)

%!error <Matrix det == 0; not invertible.>
%! % det 0
%! syms a;
%! A = [a a; a a];
%! inv(A)
