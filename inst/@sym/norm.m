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
%% @defmethod  @@sym norm (@var{A})
%% @defmethodx @@sym norm (@var{v})
%% @defmethodx @@sym norm (@var{A}, @var{ord})
%% Symbolic vector/matrix norm.
%%
%% The first argument can either be a matrix @var{A} or a
%% matrix @var{v}.
%% The second argument @var{ord} defaults to 2.
%%
%% Matrix example:
%% @example
%% @group
%% A = sym([8 1 6; 3  5  7; 4  9  2]);
%% norm (A)
%%   @result{} (sym) 15
%% norm (A, 2)
%%   @result{} (sym) 15
%% norm (A, 'fro')
%%   @result{} (sym) √285
%% @end group
%% @end example
%%
%% Vector example:
%% @example
%% @group
%% syms a positive
%% v = sym([1; a; 2]);
%% norm (v)
%%   @result{} (sym)
%%          ________
%%         ╱  2
%%       ╲╱  a  + 5
%%
%% norm (v, 1)
%%   @result{} (sym) a + 3
%% norm (v, inf)
%%   @result{} (sym) Max(2, a)
%% @end group
%% @end example
%%
%% @seealso{@@sym/svd}
%% @end defmethod


function z = norm(x, ord)

  if (nargin < 2)
    ord = 'meh';
    line1 = 'x = _ins[0]; ord = 2';
  else
    line1 = '(x,ord) = _ins';
  end

  if (ischar(ord))
    if (~strcmp(ord, 'fro') && ~strcmp(ord, 'meh'))
      error('invalid norm')
    end
  else
    ord = sym(ord);
  end

  cmd = { line1 ...
          'if not x.is_Matrix:' ...
          '    x = sympy.Matrix([x])' ...
          'return x.norm(ord),' };

  z = pycall_sympy__ (cmd, sym(x), ord);

end


%!assert (isequal (norm(sym(-6)), 6))

%!test
%! % 2-norm default
%! A = [1 2; 3 4];
%! n1 = norm (sym (A));
%! assert (isequal (n1, sqrt (sqrt (sym(221)) + 15)))
%! assert (norm (A), double (n1), -eps)

%!test
%! syms x y real
%! assert (isequal (norm([x 1; 3 y], 'fro'), sqrt(x^2 + y^2 + 10)))

%!test
%! syms x real
%! assert (isequal (norm([x 1], 2), sqrt(x^2 + 1)))

%!test
%! % test sym vs double ord
%! syms x
%! assert (isequal (norm([x 2 1], 1), abs(x) + 3))
%! assert (isequal (norm([x 2 1], sym(1)), abs(x) + 3))
%! assert (isequal (norm([sym(-3) 2 1], inf), sym(3)))
%! assert (isequal (norm([sym(-3) 2 1], sym(inf)), sym(3)))

