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
%% @deftypefn {Function File} {@var{r} =} isAlways (@var{eq})
%% Test if expression is mathematically true.
%%
%% Example:
%% @example
%% syms x
%% isAlways(x*(1+y) == x+x*y)
%% @end example
%% This returns @code{true}, in contrast with
%% @code{logical(x*(1+y) == x+x*y)}
%% which returns @code{false}.
%%
%% Note using this in practice often falls back to
%% @@logical/isAlways (which we provide, essentially a no-op), in
%% case the result has already simplified to double == double.
%% Here is an example:
%% @example
%% syms xx
%% isAlways (sin(x) - sin(x) == 0)
%% @end example
%%
%% @seealso{logical, isequal, eq (==)}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function r = isAlways(p)

  cmd = [ '(p,) = _ins\n'  ...
          'r = sp.simplify(p.lhs-p.rhs) == 0\n'  ...
          'return (r,)' ];
  r = python_cmd (cmd, p);

  if (~ islogical(r))
    error('nonboolean return from python');
  end
