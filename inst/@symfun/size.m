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
%% @deftypemethod  @@symfun {@var{d} =} size (@var{x})
%% @deftypemethodx @@symfun {[@var{n}, @var{m}] =} size (@var{x})
%% @deftypemethodx @@symfun {@var{d} =} size (@var{x}, @var{dim})
%% Return the size of a symbolic function.
%%
%% This behaves differently than for @@sym:
%% @example
%% @group
%% syms x y
%% f(x, y) = [1 x; y 2];
%%
%% size(f)
%%   @result{} 1  1
%% @end group
%%
%% @group
%% length(f)
%%   @result{} 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/size}
%% @end deftypemethod

function [n, m] = size(x, dim)

  n = [1 1];
  if (nargin == 2) && (nargout == 2)
    print_usage ();
  elseif (nargout == 2)
    m = 1;
    n = 1;
  elseif (nargin == 2)
    n = 1;
  end

end


%!test
%! syms x
%! f(x) = x;
%! d = size(f);
%! assert (isequal (d, [1 1]))
%! [n, m] = size(f);
%! assert (isequal ([n m], [1 1]))
%! assert (size(f, 1) == 1)
%! assert (size(f, 2) == 1)

%!test
%! syms x
%! f(x) = [1 x];
%! d = size(f);
%! assert (isequal (d, [1 1]))
%! [n, m] = size(f);
%! assert (isequal ([n m], [1 1]))
%! assert (size(f, 1) == 1)
%! assert (size(f, 2) == 1)
