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
%% @deftypefun check_assumptions (@var{x})
%% Check if the input have valid assumptions.
%%
%% Private helper function.
%%
%% @seealso{sym}
%% @end deftypefun


function check_assumptions (x)

  ca_helper (x)

end

%% Is safer use a helper when private functions call it self for classdef.
function ca_helper (x)

  persistent valid_asm

  if (isempty (valid_asm))
    valid_asm = assumptions ('possible');
  end

  if (~islogical (x))
    if (isa (x, 'char'))
      assert (ismember (x, valid_asm), ['sym: the assumption "' x '" is not supported in your Sympy version.'])
    elseif (isstruct (x))
      fields = fieldnames (x);
      for j = 1:numel (fields)
        ca_helper (fields{j})
      end
    elseif (iscell (x))
      for j = 1:length (x)
        ca_helper (x{j})
      end
    else
      error ('sym: assumption must be a string or struct or cell')
    end
  end

end
