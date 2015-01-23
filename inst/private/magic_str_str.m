%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{s} =} magic_str_str (@var{x})
%% Recognize special string values and substitute others.
%%
%% Private function.
%%
%% @seealso{sym, vpa}
%% @end deftypefn

function s = magic_str_str(x, varargin)

  if (~ischar(x))
    error('OctSymPy:magic_str_str:notstring', ...
          'Expected a string');
  end

  if (strcmpi(x, 'inf')) || (strcmpi(x, '+inf'))
    s = 'oo';
  elseif (strcmpi(x, '-inf'))
    s = '-oo';
  elseif (strcmpi(x, 'i'))
    s = 'I';
  else
    s = x;
  end

end
