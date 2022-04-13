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
%% @defmethod @@sym normalizethetaset (@var{x})
%% Normalize a Real Set thetatheta in the Interval [0, 2*pi).
%% It returns a normalized value of theta in the Set.
%%
%% Example:
%% @example
%% @group
%% normalizethetaset (interval (sym (pi) * 9 / 2, 5 * sym (pi)))
%%   @result{} ans = (sym)
%%       ⎡π   ⎤
%%       ⎢─, π⎥
%%       ⎣2   ⎦
%% @end group
%% @end example
%%
%% @end defmethod


function y = normalizethetaset(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: normalize_theta_set(x)', sym (x));
end


%!test
%! a = normalizethetaset (interval (sym (pi) * -3, sym (pi) / 2));
%! b = interval (sym (0), 2 * sym (pi), false, true);
%! assert (isequal (a, b))

%!test
%! a = normalizethetaset (interval (-sym (pi) / 2, sym (pi) / 2));
%! b = interval (sym (0), sym (pi) / 2) + interval (sym (pi) * 3 / 2, sym (pi) * 2, false, true);
%! assert (isequal (a, b))
