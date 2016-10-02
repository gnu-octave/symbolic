%% Copyright (C) 2014 Colin B. Macdonald
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

function A = make_sym_matrix(As, varargin)
% private helper function for making symbolic matrix

  assert (ischar (As));
  %%Wait Flatten
  cmd = { 'As = _ins[0]; sz = _ins[1:]'
          'return sympy.MatrixSymbol(As, *sz),' };
  A = python_cmd (cmd, As, varargin{:});

end
