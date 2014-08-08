%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{r} =} isequal (@var{f}, @var{g})
%% @deftypefnx {Function File} {@var{r} =} isequal (@var{f}, @var{g}, ...)
%% Test if contents of two or more arrays are equal.
%%
%% Here nan's are considered nonequal, see also @code{isequaln}
%% where @code{nan == nan}.
%%
%% Note the type of the arrays is not considered, just their shape
%% and values.
%%
%% @seealso{logical, isAlways, eq (==), isequaln}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function t = isequal(x, y, varargin)

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
