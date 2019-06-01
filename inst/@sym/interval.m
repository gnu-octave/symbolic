%% Copyright (C) 2016-2017, 2019 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
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
%% @defmethod  @@sym interval (@var{A}, @var{B})
%% @defmethodx @@sym interval (@var{A}, @var{B}, @var{lopen})
%% @defmethodx @@sym interval (@var{A}, @var{B}, @var{lopen}, @var{ropen})
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
%%   @result{} (sym) @{1@}
%% interval(sym(2), 1)
%%   @result{} (sym) ∅
%% @end group
%% @end example
%%
%% @seealso{finiteset, @@sym/union, @@sym/intersect, @@sym/setdiff, @@sym/unique, @@sym/ismember}
%% @end defmethod


function I = interval(varargin)

  if (nargin < 2 || nargin > 4)
    print_usage();
  end

  for i = 1:nargin
    varargin{i} = sym(varargin{i});
  end

  I = pycall_sympy__ ('return Interval(*_ins),', varargin{:});

end


%!test
%! a = interval(sym(1), 2);
%! assert (isa (a, 'sym'))

%!test
%! % some set subtraction
%! a = interval(sym(0), 4);
%! b = interval(sym(0), 1);
%! c = interval(sym(1), 4, true);
%! q = a - b;
%! assert (isequal( q, c))
