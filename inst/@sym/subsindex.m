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
%% @defop  Method   @@sym subsindex {(@var{x})}
%% @defopx Operator @@sym {@var{A}(sym(@var{x}))} {}
%% Used to implement indexing by sym.
%%
%% Note returns zero-based index.
%%
%% This function should not need to be called directly, but it
%% is used internally, for example in:
%% @example
%% @group
%% A = sym([10 11]);
%% A(sym(1))
%%   @result{} (sym) 10
%%
%% A(sym(2)) = sym('x')
%%   @result{} A = (sym) [10  x]  (1×2 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/subsref, @@sym/subsasgn, @@sym/end}
%% @end defop

function b = subsindex(x)

  % check if all bool or all integer
  cmd = {
      '(A,) = _ins'
      'if A is None:'
      '    return 0'
      'if not A.is_Matrix:'
      '    A = sp.Matrix([A])'
      'if all([x.is_Integer for x in A]):'
      '    return 1,'
      'elif all([x in (S.true, S.false) for x in A]):'
      '    return 2,'
      'else:'
      '    return 0,' };

  flag = pycall_sympy__ (cmd, x);

  assert(isnumeric(flag))

  if (flag == 0)
    error('OctSymPy:subsindex:values', 'subscript indices must be integers or boolean');
  elseif (flag == 1)
    % integer
    b = double(x) - 1;  % zero-based
  elseif (flag == 2)
    % boolean
    b = find(logical(x)) - 1;  % zero-based
  else
    error('subsindex: programming error');
  end

end


%!test
%! i = sym(1);
%! a = 7;
%! assert(a(i)==a);
%! i = sym(2);
%! a = 2:2:10;
%! assert(a(i)==4);

%!test
%! i = sym([1 3 5]);
%! a = 1:10;
%! assert( isequal (a(i), [1 3 5]))

%!test
%! i = sym([1 3 5]);
%! a = sym(1:10);
%! assert( isequal (a(i), sym([1 3 5])));

%!test
%! % should be an error if it doesn't convert to double
%! syms x
%! a = 1:10;
%! try
%!   a(x)
%!   waserr = false;
%! catch
%!   waserr = true;
%! end
%! assert(waserr)

%!test
%! syms x
%! assert (isequal (x(sym (true)), x))
%! assert (isequal (x(sym (false)), sym ([])))

%!test
%! x = 6;
%! assert (isequal (x(sym (true)), 6))
%! assert (isequal (x(sym (false)), []))

%!test
%! a = sym([10 12 14]);
%! assert (isequal (a(sym ([true false true])), a([1 3])))
%! assert (isequal (a(sym ([false false false])), sym (ones(1,0))))

%!test
%! a = [10 11; 12 13];
%! p = [true false; true true];
%! assert (isequal (a(sym (p)), a(p)))
%! p = [false false false];
%! assert (isequal (a(sym (p)), a(p)))

%!error <indices must be integers or boolean>
%! a = [10 12];
%! I = [sym(true) 2];
%! b = a(I);
