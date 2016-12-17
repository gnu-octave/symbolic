%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod @@sym isnan (@var{x})
%% Return true if a symbolic expression is Not-a-Number.
%%
%% Example:
%% @example
%% @group
%% A = [sym(1) sym(0)/0 sym(1)/0; sym(nan) 1 2]
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡ 1   nan  zoo⎤
%%       ⎢             ⎥
%%       ⎣nan   1    2 ⎦
%% isnan(A)
%%   @result{} ans =
%%       0   1   0
%%       1   0   0
%% @end group
%% @end example
%%
%% Note that the return is of type logical.
%%
%% @seealso{@@sym/isinf, @@sym/double}
%% @end defmethod


function r = isnan(x)

  if (nargin ~= 1)
    print_usage ();
  end

  r = uniop_bool_helper(x, 'lambda a: a is sp.nan');

end


%!shared x,zoo,oo,snan
%! oo = sym(inf);
%! zoo = sym('zoo');
%! x = sym('x');
%! snan = sym(nan);

%!test
%! % various ops that give nan
%! assert (isnan(0*oo))
%! assert (isnan(0*zoo))
%! assert (isnan(snan))
%! assert (isnan(snan-snan))
%! assert (isnan(oo+snan))
%! assert (isnan(oo-oo))
%! assert (isnan(oo-zoo))
%! assert (isnan(oo+zoo))
%! assert (~isnan(oo))
%! assert (~isnan(zoo))
%! assert (~isnan(oo+oo))

%!test
%! % more ops give nan
%! assert(isnan(x+snan))
%! assert(isnan(x*snan))
%! assert(isnan(0*snan))
%! assert(isnan(x+nan))
%! assert(isnan(x*nan))
%! assert(isnan(sym(0)*nan))

%!test
%! % array
%! assert (isequal(  isnan([oo zoo]),    [0 0]  ))
%! assert (isequal(  isnan([10 snan]),   [0 1]  ))
%! assert (isequal(  isnan([snan snan]), [1 1]  ))
%! assert (isequal(  isnan([snan x]),    [1 0]  ))

%!test
%! % sub in to algebraic expression gives nan
%! y = x - oo;
%! y = subs(y, x, oo);
%! assert(isnan(y))

%!test
%! % Must not contain string 'symbol'; these all should make an
%! % actual nan.  Actually a ctor test, not isnan.
%! y = sym(nan);
%! assert (isempty (strfind (sympy (y), 'Symbol')))
%! y = sym('nan');
%! assert (isempty (strfind (sympy (y), 'Symbol')))
%! y = sym('NaN');
%! assert (isempty( strfind (sympy (y), 'Symbol')))
