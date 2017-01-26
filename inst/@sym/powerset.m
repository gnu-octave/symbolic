%% Copyright (C) 2017 Lagu
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
%% @defmethod @@sym powerset (@var{x})
%% Find the Power set of @var{x}.
%%
%% Example:
%% @example
%% @group
%% powerset (domain ('EmptySet'))
%%   @result{} ans = (sym) @{∅@}
%% @end group
%% @end example
%%
%% @example
%% @group
%% powerset (finiteset (1, 2, 3))
%%   @result{} ans = (sym) @{∅, @{1@}, @{2@}, @{3@}, @{1, 2@}, @{1, 3@}, @{2, 3@}, @{1, 2, 3@}@}
%% @end group
%% @end example
%%
%% @end defmethod


function y = powerset(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.powerset()', sym (x));
end


%!test
%! a = finiteset (1, 2, 3, 4);
%! b = finiteset (4, 3, 2, 1);
%! assert (isAlways (powerset (a) == powerset (b)))
