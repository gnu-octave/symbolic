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
%% @deftypefun check_assumptions (@var{x}, @var{dot})
%% Check if the input have valid assumptions.
%%
%% Private helper function.
%%
%% @seealso{sym}
%% @end deftypefun

function [s, flag] = check_assumptions(varargin)

  persistent valid_asm

  if isempty(valid_asm)
    valid_asm = assumptions('possible');
  end

  for n=1:length(varargin)
    if isa(varargin{n}, 'char')
      assert(ismember(varargin{n}, valid_asm), ['sym: the assumption "' varargin{n} '" is not supported'])
    elseif isstruct(varargin{n})
      fields = fieldnames(varargin{n});
      for j=1:numel(fields)
         assert(ismember(fields{j}, valid_asm), ['sym: the assumption "' varargin{n} '" is not supported'])
      end
    elseif iscell(varargin{n})
      for j=1:length(varargin{n})
        check_assumptions(varargin{n}{j})
      end
    else
      error('sym: assumption must be a string or struct or cell')
    end
  end

end
