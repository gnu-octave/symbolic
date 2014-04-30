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
%% @deftypefn {Function File} {@var{r} =} isequal (@var{f}, @var{g})
%% Test if two symbolic arrays are same.
%%
%% Here nan's are considered nonequal, see also @code{isequaln}
%% where @code{nan == nan}.
%%
%% @seealso{logical, isAlways, eq (==), isequaln}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function t = isequal(x,y,varargin)

  if (any(isnan(x)))
    % at least on sympy 0.7.4, 0.7.5, nan == nan is true so we
    % detect is ourselves
    t = false;
  else
    t = isequaln(x,y,varargin{:});
  end
