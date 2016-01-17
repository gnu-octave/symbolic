%% Copyright (C) 2016 Colin B. Macdonald and Lagu
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
%% @deftypefn  {Function File} {@var{r} =} interval (@var{A}, @var{B})
%% @deftypefnx {Function File} {@var{r} =} interval (@var{A}, @var{B}, @var{lopen})
%% @deftypefnx {Function File} {@var{r} =} interval (@var{A}, @var{B}, @var{lopen}, @var{ropen})
%% Return an interval.
%%
%% Examples:
%% @example
%% @group
%% interval(sym(0), sym(1))
%%   @result{} (sym) [0, 1]
%% interval(sym(0), 1, true, true)
%%   @result{} (sym) (0, 1)
%% interval(sym(0), 1, false, true)
%%   @result{} (sym) [0, 1)
%% @end group
%% @end example
%%
%% Intervals can be degenerate:
%% @example
%% @group
%% interval(sym(1), 1)
%%   @result{} (sym) {1}
%% interval(sym(2), 1)
%%   @result{} (sym) ∅
%% @end group
%% @end example
%%
%% @seealso{union, intersect, setdiff, unique, ismember}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function I = interval(a, b, varargin)

  if (nargin < 2 || nargin > 4)
    print_usage();
  end

  I = python_cmd ('return Interval(*_ins),', sym(a), sym(b), varargin{:});

end


%!test
%! a = interval(sym(1), 2);
%! assert (isa (a, 'sym'))
