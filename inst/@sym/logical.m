%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{r} =} logical (@var{eq})
%% Test if expression is "structurally" true.
%%
%% This should probably be used with if/else flow control.
%%
%% Example:
%% @example
%% logical(x*(1+y) == x*(y+1))    % true
%% logical(x == y)    % false
%% @end example
%%
%% Note this is different from @code{isAlways}.
%% FIXME: doc better.
%%
%% Example:
%% @example
%% isAlways(x*(1+y) == x+x*y)    % true
%% logical(x*(1+y) == x+x*y)   % false!
%% @end example
%%
%% @seealso{isAlways, isequal, eq (==)}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = logical(p)

  if ~(isscalar(p))
    warning('logical not implemented for arrays (?) todo?');
  end

  cmd = [ '(e,) = _ins\n'  ...
          'r = bool(e.lhs == e.rhs)\n'  ...
          'return (r,)' ];
  r = python_cmd (cmd, p);

  if ~islogical(r)
    disp('logical: cannot happen?  wrong pickle?  Bug?')
    r
    keyboard
    error('unexpected return value')
  end
