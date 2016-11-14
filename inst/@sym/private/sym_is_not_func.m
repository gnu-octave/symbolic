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
%% @deftypefun sym_is_not_func (@var{x})
%% Detect if @var{x} is a octave function.
%%
%% Private helper function.
%%
%% @seealso{sym}
%% @end deftypefun


function sym_is_not_func (varargin)

  snf_helper (varargin{:});

end

%% Is safer use a helper function in private functions. 
function snf_helper(varargin)

  for i = 1:length (varargin)

    if (iscell (varargin{i}))
      for j = 1:length (varargin{i})
        snf_helper (varargin{i}{j});
      end
    elseif (isa (varargin{i}, 'char'))
      p = regexp (varargin{i}, '\(', 'split'){1};
      [x, flag] = const_to_python_str (p);
      if (~flag)
        k = exist (p);
        if (k == 5 || k == 8 || k == 2)
          disp (['warning: The expression "' varargin{i} '" its a system expression.']);
          warning ('You are overloading/hiding, if your function have the same number of args as the system expression.');
        end
      end
    elseif (isa (varargin{i}, 'sym'))
      snf_helper (varargin{i}.flat);
    else
      error ('Input not supported yet.');
    end
 
  end

end
