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
%% @defmethod @@sym isfinite (@var{x})
%% Is symbolic expression finite.
%%
%% A number is finite if it is neither infinite (@pxref{@@sym/isinf})
%% nor NaN (@pxref{@@sym/isnan}), for example:
%% @example
%% @group
%% isfinite (sym(42))
%%   @result{} ans =  1
%% isfinite (sym(inf))
%%   @result{} ans =  0
%% isfinite (sym(nan))
%%   @result{} ans =  0
%% @end group
%% @end example
%%
%% However for symbolic @emph{expressions}, the situation is more
%% complicated, for example we cannot be sure @code{x} is finite:
%% @example
%% @group
%% syms x
%% isfinite (x)
%%   @result{} ans =  0
%% @end group
%% @end example
%% Of course, we also cannot be sure @code{x} is infinite:
%% @example
%% @group
%% isinf (x)
%%   @result{} ans =  0
%% @end group
%% @end example
%%
%% Assumptions play a role:
%% @example
%% @group
%% syms x finite
%% isfinite (x)
%%   @result{} ans =  1
%% @end group
%%
%% @group
%% isfinite (1/x)            % x could be zero
%%   @result{} ans =  0
%%
%% syms y positive finite
%% isfinite (1/y)
%%   @result{} ans =  1
%% @end group
%% @end example
%%
%% @seealso{@@sym/isinf, @@sym/isnan}
%% @end defmethod

function r = isfinite(x)

  if (nargin ~= 1)
    print_usage ();
  end

  r = uniop_bool_helper(x, 'lambda a: a.is_finite');

end


%!assert (isfinite(sym(1)))
%!assert (isfinite(sym(-10)))
%!assert (~isfinite(sym('oo')))
%!assert (~isfinite(sym('-oo')))
%!assert (~isfinite(sym(1)/0))
%!assert (~isfinite(sym(nan)))
%!assert (isequal (isfinite (sym ([1 inf])), [true false]))

%!test
%! % finite-by-assumption
%! syms x finite
%! assert (isfinite (x))
