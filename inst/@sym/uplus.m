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
%% @defop  Method   @@sym uplus (@var{x})
%% @defopx Operator @@sym {+@var{x}} {}
%% Symbolic unitary minus.
%%
%% A no-op.  Example:
%% @example
%% @group
%% syms x
%% +x
%%   @result{} (sym) x
%% @end group
%% @end example
%% @seealso{@@sym/uminus}
%% @end defop

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function x = uplus(x)

  % no-op

end


%!test
%! syms x
%! assert (isa (+x, 'sym'))
%! assert (isequal (+x, x))

%!test
%! A = sym([0 -1 inf]);
%! assert( isequal ( +A, A))
