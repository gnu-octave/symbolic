%% Copyright (C) 2016 Colin B. Macdonald
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
%% @documentencoding UTF-8
%% @defmethod  @@sym dilog (@var{z})
%% Symbolic dilogarithm function.
%%
%% Example:
%% @example
%% @group
%% syms z
%% dilog (z)
%%   @result{} ans = (sym) polylog(2, -z + 1)
%% @end group
%% @end example
%%
%% @seealso{@@sym/polylog}
%% @end defmethod

function L = dilog(z)
  if (nargin ~= 1)
    print_usage ();
  end

  L = polylog(2, 1 - z);
end


%!assert (isequal (dilog (sym(1)), sym(0)))
%!assert (isequal (dilog (sym(0)), sym(pi)^2/6))
%!assert (isequal (dilog (sym(2)), -sym(pi)^2/12))

%!assert (double(dilog(sym(-1))), pi^2/4 - pi*1i*log(2), eps)
