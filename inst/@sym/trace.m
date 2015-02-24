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
%% @deftypefn  {Function File} {@var{B} =} trace (@var{A})
%% Trace of symbolic matrix.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = trace(x)

  cmd = { 'x, = _ins'
          'if not x.is_Matrix:'
          '    x = sp.Matrix([[x]])'
          'return sp.trace(x),' };

  z = python_cmd (cmd, x);

end


%!test
%! % scalar
%! syms x
%! assert (isequal (trace(x), x))

%!test
%! syms x
%! A = [x 3; 2*x 5];
%! assert (isequal (trace(A), x + 5))
