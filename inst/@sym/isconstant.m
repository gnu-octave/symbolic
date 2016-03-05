%% Copyright (C) 2014-2016 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn {Function File}  {@var{y} =} isconstant (@var{x})
%% Indicate which elements of symbolic array are constant.
%%
%% @seealso{isallconstant, symvar, findsymbols}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = isconstant(x)

  cmd = { '(x,) = _ins'
          'if x is not None and x.is_Matrix:'
          '    return x.applyfunc(lambda a: a.is_constant()),'
          'return x.is_constant(),' };
  z = python_cmd (cmd, sym(x));
  % Issue #27: Matrix of bools not converted to logical
  z = logical(z);

end


%!test
%! syms x
%! A = [x 2 3];
%! B = [false true true];
%! assert (isequal (isconstant(A), B))

%!test
%! syms x
%! A = [x 2; 3 x];
%! B = [false true; true false];
%! assert (isequal (isconstant(A), B))
