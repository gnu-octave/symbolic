%% Copyright (C) 2014, 2015, 2019 Colin B. Macdonald
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

function z = numeric_array_to_sym(A)
%private helper for sym ctor
%   convert an array to syms, currently on 1D, 2D.

  [n, m] = size(A);

  if (n == 0 || m == 0)
    cmd = { sprintf('return sp.Matrix(%d, %d, []),', n, m) };
    z = pycall_sympy__ (cmd);
    return
  end

  Ac = cell(n,1);
  for i=1:n
    % we want all sym creation to go through the ctor.
    Ac{i} = cell(m,1);
    for j=1:m
      Ac{i}{j} = sym(A(i,j));
    end
  end

  %Ac = {{x 2}; {3 4}; {8 9}};

  d = size(A);
  if (length(d) > 2)
    error('conversion not supported for arrays of dim > 2');
  end

  cmd = { 'L = _ins[0]'
          'M = sp.Matrix(L)'
          'return M,' };
  z = pycall_sympy__ (cmd, Ac);
