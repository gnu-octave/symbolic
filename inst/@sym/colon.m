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
%% @defop  Method   @@sym colon {(@var{a}, @var{b})}
%% @defopx Method   @@sym colon {(@var{a}, @var{step}, @var{b})}
%% @defopx Operator @@sym {@var{a}:@var{b}} {}
%% @defopx Operator @@sym {@var{a}:@var{step}:@var{b}} {}
%% Generate a range of symbolic expressions.
%%
%% Examples:
%% @example
%% @group
%% sym(5):10
%%   @result{} ans = (sym) [5  6  7  8  9  10]  (1×6 matrix)
%% 0:sym(pi):5*sym(pi)
%%   @result{} ans = (sym) [0  π  2⋅π  3⋅π  4⋅π  5⋅π]  (1×6 matrix)
%% syms x
%% x:2:(x+6)
%%   @result{} ans = (sym) [x  x + 2  x + 4  x + 6]  (1×4 matrix)
%% @end group
%% @end example
%%
%% The end point @var{b} might not be included:
%% @example
%% @group
%% 0:sym(pi):10
%%   @result{} ans = (sym) [0  π  2⋅π  3⋅π]  (1×4 matrix)
%% @end group
%% @end example
%%
%% The @var{step} can be negative:
%% @example
%% @group
%% sym(6):-3:-3
%%   @result{} ans = (sym) [6  3  0  -3]  (1×4 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/linspace}
%% @end defop


function y = colon(a, step, b)

  if (nargin == 2)
    b = step;
    step = sym(1);
  end

  cmd = { '(a, b, step) = _ins'
          'B = floor((b-a)/step)'
          'y = Matrix([range(0, B+1)])'
          'y = y*step + Matrix([[a]*y.cols])'
          'return y,' };

  y = pycall_sympy__ (cmd, sym(a), sym(b), sym(step));

end


%!test
%! a = sym(1):5;
%! b = sym(1:5);
%! assert(isequal(a,b));
%! a = 1:sym(5);
%! b = sym(1:5);
%! assert(isequal(a,b));

%!test
%! a = 2:sym(2):8;
%! b = sym(2:2:8);
%! assert(isequal(a,b));

%!test
%! a = sym(10):-2:-4;
%! b = sym(10:-2:-4);
%! assert(isequal(a,b));

%!test
%! % symbolic intervals
%! p = sym(pi);
%! L = 0:p/4:p;
%! assert(isa(L,'sym'));
%! assert(isequal(L, [0 p/4 p/2 3*p/4 p]));

%!test
%! % mixed symbolic and double intervals
%! p = sym(pi);
%! s = warning ('off', 'OctSymPy:sym:rationalapprox');
%! L = 0.1:(sym(pi)/3):2.3;
%! warning(s)
%! assert(isa(L,'sym'));
%! t = sym(1)/10;
%! assert(isequal(L, [t p/3+t 2*p/3+t]));

%!error syms x; a = 0:x;
%!error syms x; a = 1:x;
