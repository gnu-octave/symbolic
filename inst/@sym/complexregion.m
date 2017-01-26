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
%% @defmethod @@sym complexregion (@var{x}, @var{y})
%% Represents the Set of all Complex Numbers.
%% It can represent a region of Complex Plane in 
%% both the standard forms Polar and Rectangular coordinates.
%% Where @var{x} are the interval and if @var{y} is true
%% you will get the polar form, if is not specified or is false
%% it will be constructed in rectangular form.
%%
%% Example for rectangular form:
%% @example
%% @group
%% a = interval (sym (0), 2);
%% b = interval (sym (5), 7);
%% complexregion (a * b)
%%   @result{} ans = (sym) @{x + y⋅ⅈ | x, y ∊ [0, 2] × [5, 7]@}
%% @end group
%% @end example
%%
%% Example for polar form:
%% @example
%% @group
%% a = interval (sym (1), 2);
%% b = interval (sym (0), sym (pi) * 2);
%% complexregion (a * b, true)
%%   @result{} ans = (sym) @{r⋅(ⅈ⋅sin(θ) + cos(θ)) | r, θ ∊ [1, 2] × [0, 2⋅π)@}
%% @end group
%% @end example
%%
%% @end defmethod


function y = complexregion(x, y)
  if (nargin > 2)
    print_usage ();
  elseif nargin == 1
    y = false;
  end
  y = elementwise_op ('lambda x, y: ComplexRegion(x, polar=y)', sym (x), logical (y));
end


%% This function is tested in @sym/ainterval, @sym/binterval
%% @sym/ispolar, @sym/psets, @sym/sets and @sym/normalizethetaset
