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
%% @defmethod @@sym rangeset (@var{stop})
%% @defmethodx @@sym rangeset (@var{start}, @var{stop})
%% @defmethodx @@sym rangeset (@var{start}, @var{stop}, @var{step})
%% @defmethodx @@sym rangeset (@var{start}, @var{stop}, @var{step}, @var{list})
%% Represents a range of integer from @var{start} to @var{stop} in @var{step} steps.
%% If you ignore some of this values it will takes this be default:
%% @var{start}: 0
%% @var{stop} : 1
%% @var{step} : 1
%%
%% If you set @var{list} to 'list', this will return the list of values
%% instead the set representation. 
%%
%% Example:
%% @example
%% @group
%% rangeset (sym (10), 0, -2)
%%   @result{} ans = (sym) @{2, 4, …, 10@}
%% @end group
%% @end example
%%
%% @example
%% @group
%% rangeset (sym (0), 20, 3, 'list')
%%   @result{} ans = (sym) [0  3  6  9  12  15  18]  (1×7 matrix)
%% @end group
%% @end example
%%
%% @end defmethod


function y = rangeset(varargin)
  if (nargin > 4 || nargin < 1)
    print_usage ();
  end

  %% Note, in Sympy 1.0 the negative steps produce a sorted
  %% output, over 1.0 don't is sorted.

  if strcmp (varargin{nargin}, 'list')
    varargin = cellfun(@sym, varargin, 'UniformOutput', false);
    y = python_cmd ('return list(Range(*_ins)),', varargin{1:3});
    y = cell2sym (y);
  else
    varargin = cellfun(@sym, varargin, 'UniformOutput', false);
    y = python_cmd ('return Range(*_ins),', varargin{:});
  end

end


%!test
%! a = rangeset (sym (1), 5);
%! assert (logical (isemptyset (intersect (a, interval (sym (6), inf)))))
