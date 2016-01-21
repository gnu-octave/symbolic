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
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{tf} =} ismember (@var{x}, @var{S})
%% @deftypefnx {Function File} {@var{Z} =}  ismember (@var{x}, @var{M})
%% Test if an object is contained within a set or a matrix.
%%
%% This function can be used in two ways, the first is to check
%% if @var{x} is contained in a set @var{S}:
%% @example
%% @group
%% I = interval(sym(0), sym(pi));
%% ismember(2, I)
%%   @result{} ans = 1
%% @end group
%% @end example
%%
%% It can also be used to check if @var{x} is contained in a
%% matrix @var{M}:
%% @example
%% @group
%% B = [sym(1) 2; 2*sym(pi) 4];
%% ismember(sym(pi), B)
%%   @result{} ans = 0
%% @end group
%% @end example
%%
%% In either case, the first argument @var{x} can also be a matrix:
%% @example
%% @group
%% A = [sym(3), 4 2; sym(1) 0 1];
%% ismember(A, B)                       % doctest: +XFAIL
%%   @result{} ans =
%%        0   1   1
%%        1   0   1
%% @end group
%% @end example
%%
%% @seealso{lookup, unique, union, intersect, setdiff, setxor}
%% @end deftypefn

function r = ismember(x, y)

  cmd = {
         'x, y = _ins'
         'if not isinstance(x, sp.MatrixBase):'
         '    return x in y,'
         'elif len(x) == 1:'
         '    return x in y,'
         'for i, b in enumerate(x):'
         '    x[i] = b in y'
         'return x,'
        };

  r = python_cmd (cmd, sym(x), sym(y));
  %r = logical(r);

end


%!assert (ismember (2, interval(sym(0),2)))
%!assert (~ismember (3, interval(sym(0),2)))

%!test
%! % something in a matrix
%! syms x
%! A = [1 x; sym(pi) 4];
%! assert (ismember (sym(pi), A))
%! assert (ismember (x, A))
%! assert (~ismember (2, A))

%!test
%! % set
%! syms x
%! %FIXME: replace with finiteset later
%! %S = finiteset(2, sym(pi), x)
%! S = interval(sym(2),2) + interval(sym(pi),pi) + interval(x,x);
%! assert (ismember (x, S))

%!test
%! % set with positive symbol
%! syms x positive
%! S = interval(sym(2),2) + interval(sym(pi),pi) + interval(x,x);
%! assert (~ismember (-1, S))

%!error
%! % set with symbol can be indeterminant
%! syms x
%! S = interval(sym(2),2) + interval(sym(pi),pi) + interval(x,x);
%! assert (~ismember (-1, S))
