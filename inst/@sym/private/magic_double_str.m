%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @deftypefun {[@var{s}, @var{flag}] =} magic_double_str (@var{x}, @var{in})
%% Recognize special double values.
%%
%% Private helper function.
%%
%% Caution: there are two copies of this file for technical
%% reasons: make sure you modify both of them!
%%
%% @seealso{sym, vpa}
%% @end deftypefun

function [s, flag] = magic_double_str(x, in)

  persistent list %%format: number, octave string, python expression

  if isempty(list)
    list = {pi, 'pi', 'pi';inf, 'inf', 'oo';inf, 'Inf', 'oo';nan, 'nan', 'nan';i, 'i', 'I';e, 'e', 'E'};
  end

  flag = 1;

  if strcmp(in, 'number')  %%Number comparison
    for j=1:length(list)
      if x == list{j, 1}
        s = list{j, 2};
        return
      elseif x == -list{j, 1}
        s = ['-' list{j, 2}];
        return
      end
    end
  else  %%String comparison
    for j=1:length(list)
      if strcmp(x, list{j, 2}) || strcmp(x, ['+' list{j, 2}])
        s = list{j, 3};
        return
      elseif strcmp(x, ['-' list{j, 2}])
        s = ['-' list{j, 3}];
        return
      end
    end
  end

  if strcmp(in, 'char')
    flag = 0;
    s = x;
    return
  end

  if (abs(x) < 1e15) && (mod(x,1) == 0)
    % special treatment for "small" integers
    s = num2str(x);  % better than sprintf('%d', large)
  else
    s = '';
    flag = 0;
  end

end
