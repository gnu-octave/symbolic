%% Copyright (C) 2018 Colin B. Macdonald
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
%% @defmethod  @@sym arg (@var{x})
%% @defmethodx @@sym angle (@var{x})
%% Symbolic polar angle.
%%
%% Example:
%% @example
%% @group
%% x = sym(2+3*i);
%% y = arg(x)
%%   @result{} y = (sym) atan(3/2)
%% @end group
%% @end example
%% @seealso{arg, @@sym/abs}
%% @end defmethod


function y = arg (x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('arg', x);
end


%!test
%! syms x
%! assert (isequal (angle (x), arg (x)));
