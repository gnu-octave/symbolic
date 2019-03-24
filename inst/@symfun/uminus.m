%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defop  Method   @@symfun uminus {(@var{f})}
%% @defopx Operator @@symfun {-@var{f}} {}
%% Return the negation of a symbolic function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% f(x) = 2*x;
%% h = -f
%%   @result{} h(x) = (symfun) -2⋅x
%% @end group
%% @end example
%%
%% @seealso{@@symfun/minus}
%% @end defop

function h = uminus(f)

  h = symfun(-formula(f), f.vars);

end


%!test
%! % Issue #447
%! syms x
%! f(x) = x^2;
%! assert (isa (-f, 'symfun'))

%!test
%! syms f(x)
%! h = -f;
%! assert (isa (h, 'symfun'))
