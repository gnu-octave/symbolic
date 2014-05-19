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
%% @deftypefn  {Function File} {@var{y}} transpose (@var{x})
%% Transpose of a symbolic array.
%%
%% @seealso{ctranspose}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = transpose(x)

  cmd = [ '(x,) = _ins\n'  ...
          'if x.is_Matrix:\n'  ...
          '    return (x.T,)\n' ...
          'else:\n' ...
          '    return (x,)' ];

  z = python_cmd (cmd, x);

end


%!test
%! x = sym(1);
%! assert(x.' == x)
%!assert(sym([]).' == sym([]))

%!test
%! syms x;
%! assert(x.' == x)

%!test
%! A = [1 2; 3 4];
%! assert(sym(A).' == sym(A.'))
%!test
%! A = [1 2] + 1i;
%! assert(sym(A).' == sym(A.'))
