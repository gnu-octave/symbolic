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
%% @deftypefn  {Function File} {[@var{s}, @var{flag}] =} magic_double_str (@var{x})
%% Recognize special double values.
%%
%% Private helper function.
%%
%% @seealso{sym, vpa}
%% @end deftypefn

function [s, flag] = magic_double_str(x)

  flag = 1;

  if (~isa(x, 'double') || ~isreal(x))
    error('OctSymPy:magic_double_str:notrealdouble', ...
          'Expected a real double precision number');
  end

  % NOTE: yes, these are floating point equality checks!
  if (x == pi)
    s = 'pi';
  elseif ((isinf(x)) && (x > 0))
    s = 'inf';
  elseif ((isinf(x)) && (x < 0))
    s = '-inf';
  elseif (isnan(x))
    s = 'nan';
  elseif (isreal(x) && (mod(x,1) == 0))   % is integer
    s = sprintf('%d', x);
  else
    s = '';
    flag = 0;
  end

end
