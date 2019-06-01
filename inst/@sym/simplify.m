%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym simplify (@var{x})
%% Simplify an expression.
%%
%% Example:
%% @example
%% @group
%% syms x
%% p = x^2 + x + 1
%%   @result{} p = (sym)
%%        2
%%       x  + x + 1
%% q = horner (p)
%%   @result{} q = (sym) x⋅(x + 1) + 1
%% @end group
%%
%% @group
%% d = p - q
%%   @result{} d = (sym)
%%        2
%%       x  - x⋅(x + 1) + x
%%
%% isAlways(p == q)
%%   @result{} 1
%%
%% simplify(p - q)
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% Please note that @code{simplify} is not a well-defined mathematical
%% operation: its precise behaviour can change between software versions
%% (and certainly between different software packages!)
%%
%% @seealso{@@sym/isAlways, @@sym/factor, @@sym/expand, @@sym/rewrite}
%% @end defmethod


function y = simplify(x)

  cmd = 'return sp.simplify(*_ins),';

  y = pycall_sympy__ (cmd, x);

end


%!shared x,p,q
%! syms x
%! p = x^2 + x + 1;
%! q = horner (p);
%!assert(~isequal( p - q, 0))
%!assert(isequal( simplify(p - q), 0))
