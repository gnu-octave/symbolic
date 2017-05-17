%% Copyright (C) 2015-2017 Colin B. Macdonald
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
%% @deftypefun {[@var{s}, @var{flag}] =} detect_special_str (@var{x})
%% Recognize special constants, return their sympy string equivalent.
%%
%% Private helper function.
%%
%% @seealso{sym, vpa}
%% @end deftypefun

function [s, flag] = detect_special_str (x)

  % Table of special strings.  Format for each row is:
  %    {list of strings to recognize}, resulting python expr
  % Note: case sensitive
  % Note: python expr should be in list for identity "sym(sympy(x)) == x"
  table = {{'pi'} 'S.Pi'; ...
           {'inf' 'Inf' 'oo'} 'S.Infinity'; ...
           {'NaN' 'nan'} 'S.NaN'; ...
           {'zoo'} 'S.ComplexInfinity'};

  flag = 0;
  s = x;

  assert (ischar (x))

  for j = 1:length (table)
    for n = 1:length (table{j, 1})
      if (strcmp (x, table{j, 1}{n}) || strcmp (x, ['+' table{j, 1}{n}]))
        s = table{j, 2};
        flag = 1;
        return
      elseif (strcmp (x, ['-' table{j, 1}{n}]))
        s = ['-' table{j, 2}];
        flag = 1;
        return
      end
    end
  end

end
