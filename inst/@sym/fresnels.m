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
%% @deftypefn  {Function File} {@var{z} =} fresnels (@var{x})
%% Symbolic Fresnel Sine function.
%%
%% Example:
%% @example
%% @group
%% z = fresnels(sym('x'))
%%   @result{} z = (sym) fresnels(x)
%% diff(z)
%%   @result{} (sym)
%%          ⎛   2⎞
%%          ⎜π⋅x ⎟
%%       sin⎜────⎟
%%          ⎝ 2  ⎠
%% @end group
%% @end example
%% @seealso{fresnelc}
%% @end deftypefn

function J = fresnels(x)

  J = uniop_helper(x, 'fresnels');

end


%!test
%! a = fresnels(sym(0));
%! assert (isequal (a, sym(0)))

%!test
%! b = fresnels(sym('oo'));
%! assert (isequal (b, sym(1)/2))

%!test
%! % values in a matrix
%! syms x
%! a = fresnels([sym(0)  sym('oo')  x  1]);
%! b = [sym(0)  sym(1)/2  fresnels(x)  fresnels(sym(1))];
%! assert (isequal (a, b))
