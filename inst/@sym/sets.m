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
%% @defmethod @@sym sets (@var{x})
%% Return raw input sets of @var{x}.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (2), 3);
%% b = interval (sym (4), 5);
%% c = interval (sym (1), 7);
%%
%% sets (complexregion (a * b))
%%   @result{} ans = (sym) [2, 3] × [4, 5]
%% @end group
%% @end example
%%
%% @example
%% @group
%% sets (complexregion (a * b + b * c))
%%   @result{} ans = (sym) ([2, 3] × [4, 5]) ∪ ([4, 5] × [1, 7])
%% @end group
%% @end example
%%
%% @end defmethod


function y = sets(x)
  if (nargin ~= 1)
    print_usage ();
  end

  y = elementwise_op ('lambda x: x.sets', sym (x));
end


%!test
%% a = interval (sym (1), 9);
%% b = interval (sym (4), 6);
%% sol = a * b;
%% r = sets (complexregion (a * b));
%% assert (isequal (r, sol))

%!test
%% a = interval (sym (1), 9);
%% b = interval (sym (4), 6);
%% c = interval (sym (2), 3);
%% sol = a * b + c * b;
%% r = sets (complexregion (a * b + c * b));
%% assert (isequal (r, sol))
