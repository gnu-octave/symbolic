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
%% @defmethod @@logical isAlways (@var{t})
%% Test if expression is mathematically true.
%%
%% For inputs of type logical (true/false) this is just the
%% logical itself.  The reason for having this function is
%% explained elsewhere (@pxref{@@sym/isAlways}).
%%
%% Examples:
%% @example
%% @group
%% isAlways(true)
%%   @result{} ans = 1
%% isAlways(false)
%%   @result{} ans = 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/isAlways}
%% @end defmethod


function r = isAlways(p)

  if (nargin ~= 1)
    print_usage ();
  end

  r = p;

end


%!error <Invalid> isAlways (true, false)
%!assert(isAlways(true))
%!assert(~isAlways(false))
