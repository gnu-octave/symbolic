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
%% @deftypefun @var{s} = norm_logic_strings (@var{x})
%% Convert char logicals to true logicals, for functions like:
%% syms x real false
%%
%% Private helper function.
%%
%% Caution: there are two copies of this file for technical
%% reasons: make sure you modify both of them!
%%
%% @seealso{sym}
%% @end deftypefun


function s = norm_logic_strings (x);

  if (iscell (x))
    for i = 1:length (x)
      x{i} = norm_logic_strings (x{i});
    end
  elseif (isstruct (x))
    fields = fieldnames (x);
    for q = 1:numel (fields)
      x.(fields{q}) = norm_logic_strings (x.(fields{q}));
    end
  elseif (ischar (x))
    w = lower (x);
    if (strcmp (w, 'true'))
      x = true;
    elseif (strcmp (w, 'false'))
      x = false;
    end
  elseif (isa (x, 'sym'))
    x = norm_logic_strings (x.flat);
  end

  s = x;

end
