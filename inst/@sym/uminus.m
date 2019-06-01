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
%% @defop  Method   @@sym uminus (@var{x})
%% @defopx Operator @@sym {-@var{x}} {}
%% Return the negation of a symbolic expression.
%%
%% Example:
%% @example
%% @group
%% syms x
%% -x
%%   @result{} (sym) -x
%% -(3 - 2*x)
%%   @result{} (sym) 2⋅x - 3
%% @end group
%% @end example
%% @end defop


function z = uminus(x)

  z = pycall_sympy__ ('return -_ins[0],', x);

end


%!test
%! % scalar
%! syms x
%! assert (isa (-x, 'sym'))
%! assert (isequal (-(-x), x))

%!test
%! % matrix
%! D = [0 1; 2 3];
%! A = sym(D);
%! assert( isequal( -A, -D  ))
