%% Copyright (C) 2016 Lagu
%% Copyright (C) 2019 Colin B. Macdonald
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
%% @defmethod @@sym divisors (@var{x})
%% Get divisors of integer.
%%
%% Example:
%% @example
%% @group
%% x = sym(150);
%% y = divisors(x)
%%   @result{} y = (sym) [1  2  3  5  6  10  15  25  30  50  75  150]  (1×12 matrix)
%% @end group
%% @end example
%% @end defmethod

%% Reference: http://docs.sympy.org/dev/modules/ntheory.html


function y = divisors(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = pycall_sympy__ ('return S(divisors(_ins[0])),', x);
  y = cell2sym(y);
end


%!test
%! assert( isequal( divisors(sym(150)), divisors(sym(-150)) ))
