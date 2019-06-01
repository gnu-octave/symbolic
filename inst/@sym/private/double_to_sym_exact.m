%% Copyright (C) 2017, 2019 Colin B. Macdonald
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
%% @deftypefun {@var{y} =} double_to_sym_exact (@var{x})
%% Convert a double value to the equivalent rational sym
%%
%% Private helper function.
%%
%% @end deftypefun

function y = double_to_sym_exact (x)
  if (isnan (x))
    y = pycall_sympy__ ('return S.NaN');
  elseif (isinf (x) && x < 0)
    y = pycall_sympy__ ('return -S.Infinity');
  elseif (isinf (x))
    y = pycall_sympy__ ('return S.Infinity');
  else
    %% Rational will exactly convert from a float
    y = pycall_sympy__ ('return Rational(_ins[0])', x);
  end
end
