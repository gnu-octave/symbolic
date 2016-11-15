%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym ssinint (@var{x})
%% Symbolic shifted sine integral function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = ssinint(x)
%%   @result{} y = (sym)
%%               π
%%       Si(x) - ─
%%               2
%% @end group
%% @end example
%% @seealso{@@sym/sinint}
%% @end defmethod

function y = ssinint(x)
  y = elementwise_op ('Si', x) - sym(pi)/2;
end


%!assert (isequal (ssinint(sym(0)), -sym(pi)/2))

%!test
%! A = ssinint (sym ([0 1]));
%! B = [-pi/2  -0.62471325642771360426];
%! assert( all(all( abs(double(A)-B) < 1e-15 )))
