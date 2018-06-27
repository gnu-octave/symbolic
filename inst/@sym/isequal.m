%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod  @@sym isequal (@var{f}, @var{g})
%% @defmethodx @@sym isequal (@var{f}, @var{g}, @dots{})
%% Test if contents of two or more arrays are equal.
%%
%% Example:
%% @example
%% @group
%% syms x
%% isequal([1 x], [1 x])
%%   @result{} 1
%% @end group
%% @end example
%%
%% Note NaN's compare as false:
%% @example
%% @group
%% snan = sym(nan);
%% isequal([1 snan], [1 snan])
%%   @result{} 0
%% @end group
%% @end example
%% To avoid this behaviour, @pxref{isequaln}.
%%
%% Note the type of the arrays is not considered, just their shape
%% and values.
%%
%% @seealso{@@sym/isequaln, @@sym/logical, @@sym/isAlways, @@sym/eq}
%% @end defmethod

function t = isequal(x, y, varargin)

  if (nargin < 2)
    print_usage ();
  end

  % isequal does not care about type, but if you wanted it to...
  %if ( ~ ( isa (x, 'sym') && isa (y, 'sym')))
  %  t = false;
  %  return
  %end

  if (any (any (isnan (x))))
    % at least on sympy 0.7.4, 0.7.5, nan == nan is true so we
    % detect is ourselves
    t = false;
  else
    t = isequaln(x, y, varargin{:});
  end

end


%!test
%! a = sym([1 2]);
%! b = a;
%! assert (isequal (a, b))
%! b(1) = 42;
%! assert (~isequal (a, b))

%!test
%! a = sym([1 2; 3 4]);
%! b = a;
%! assert (isequal (a, b))
%! b(1) = 42;
%! assert (~isequal (a, b))

%!test
%! a = sym([nan; 2]);
%! b = a;
%! assert (~isequal (a, b))

%!test
%! % proper nan treatment
%! a = sym([nan 2; 3 4]);
%! b = a;
%! assert (~isequal (a, b))

%!test
%! % more than two arrays
%! a = sym([1 2 3]);
%! b = a;
%! c = a;
%! assert (isequal (a, b, c))
%! c(1) = 42;
%! assert (~isequal (a, b, c))
