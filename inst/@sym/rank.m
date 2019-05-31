%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym rank (@var{A})
%% Rank of a symbolic matrix.
%%
%% Examples:
%% @example
%% @group
%% A = sym([1 1; 2 0]);
%% rank (A)
%%   @result{} ans =  2
%% @end group
%%
%% @group
%% A = sym([1 2; 1 2]);
%% rank (A)
%%   @result{} ans =  1
%% @end group
%% @end example
%%
%% @seealso{@@sym/cond, @@sym/null, @@sym/orth}
%% @end defmethod


function r = rank(A)

  cmd = { 'A = _ins[0]'
          'if not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'return A.rank(),' };

  r = pycall_sympy__ (cmd, A);

end


%!test
%! A = sym([1 2; 3 4]);
%! assert (rank(A) == 2);

%!test
%! A = sym([1 2 3; 3 4 5]);
%! assert (rank(A) == 2);

%!test
%! A = sym([1 2; 1 2]);
%! assert (rank(A) == 1);

%!test
%! A = sym([1 2; 3 4]);
%! assert (rank(A) == 2);

%!assert (rank(sym(1)) == 1);
%!assert (rank(sym(0)) == 0);
%!assert (rank(sym('x', 'positive')) == 1);
