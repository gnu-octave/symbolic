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
%% @deftypefun symsnotfunc (@var{x})
%% Detect if @var{x} is a octave function.
%%
%% Private helper function.
%%
%% @seealso{sym}
%% @end deftypefun

function [s, flag] = symsnotfunc(varargin)

  persistent exclude %% List of octave expressions can be converted to sym, for SMT compat, avoid the most possible

  if isempty(exclude)
    exclude = {'e'};
  end

  for i=1:length(varargin)

    if iscell(varargin{i})
      for j=1:length(varargin{i})
        symsnotfunc(varargin{i}{j});
      end
    elseif isa(varargin{i}, 'char')
      [x, flag] = magic_double_str(varargin{i});
      if ~flag
        k = exist(varargin{i});
        if k == 5 || k == 8 || k == 2
          error(['You can not transform "' varargin{i} '" to sym, its a system expression']);
        end
      end
    else
      error ('Input not supported yet.');
    end
 
  end

end
