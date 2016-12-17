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
%% @deftypefun {[@var{s}, @var{flag}] =} const_to_python_str (@var{x})
%% Recognize constant and return their python string equivalent.
%%
%% Private helper function.
%%
%% Caution: there are two copies of this file for technical
%% reasons: make sure you modify both of them!
%%
%% @seealso{sym, vpa}
%% @end deftypefun

function [s, flag] = const_to_python_str (x)

  persistent list % format: number, {octave string}, python expression
  persistent const % Sympy constants
  % {octave string} need contain the python expression for char function

  if (isempty (list))
    list = {pi {'pi'} 'pi';inf {'inf' 'Inf' 'oo'} 'oo';nan {'nan' 'NaN'} 'nan';i {'i' 'I'} 'I'};
    const = {'zoo'};
  end

  flag = 1;

  if (isa (x, 'double'))  % Number comparison
    for j = 1:length (list)
      if (isequaln (x, list{j, 1}))
        s = list{j, 3};
        return
      elseif (isequaln (x, -list{j, 1}))
        s = ['-' list{j, 3}];
        return
      end
    end
  elseif (isa (x, 'char'))  % Char comparison
    for j = 1:length (list)
      for n = 1:length (list{j, 2})
        if (strcmp (x, list{j, 2}{n}) || strcmp (x, ['+' list{j, 2}{n}]))
          s = list{j, 3};
          return
        elseif (strcmp (x, ['-' list{j, 2}{n}]))
          s = ['-' list{j, 3}];
          return
        end
      end
    end
    for j = 1:length (const)   % Check if is a python constant
      if (strcmp (x, const{j}) || strcmp (x, ['+' const{j}]))
        s = const{j};
        return
      elseif (strcmp (x, ['-' const{j}]))
        s = ['-' const{j}];
        return
      end
    end
  else
    error ('Format not supported.')
  end

  if (isa (x, 'char'))
    flag = 0;
    s = x;
    return
  elseif (isa (x, 'double'))
    if ((abs (x) < 1e15) && (mod (x,1) == 0))
      % special treatment for "small" integers
      s = num2str (x);  % better than sprintf('%d', large)
    else
      s = '';
      flag = 0;
    end
  end

end
