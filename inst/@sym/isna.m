%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod @@sym isna (@var{x})
%% Symbolic expressions cannot be the Octave/R missing data NA.
%%
%% Always returns false:
%% @example
%% @group
%% isna([sym(1) sym('x') sym(nan)])
%%   @result{} ans =
%%       0   0   0
%% @end group
%% @end example
%% (We have this mainly so @code{assert} works properly.)
%%
%% @seealso{@@sym/isnan}
%% @end defmethod


function r = isna(x)

  r = logical(zeros(size(x)));

end


%!test
%! % no sym should be NA
%! syms x oo
%! assert (~isna(sym(1)))
%! assert (~isna(x))
%! assert (~isna(oo))
%! assert (~isna(sym(nan)))
%! assert (isequal (isna (sym ([1 nan])), [false false]))
