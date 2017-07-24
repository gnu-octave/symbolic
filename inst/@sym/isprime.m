%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod @@sym isprime (@var{n})
%% Return true if a symbolic number is prime.
%%
%% Example:
%% @example
%% @group
%% n = sym(127);
%% m = 2^n - 1
%%   @result{} m = (sym) 170141183460469231731687303715884105727
%% isprime(m)
%%   @result{} ans =  1
%% @end group
%% @end example
%%
%% Example:
%% @example
%% @group
%% syms q negative
%% isprime(q)
%%   @result{} ans =  0
%% @end group
%% @end example
%%
%% @seealso{@@sym/nextprime, @@sym/prevprime}
%% @end defmethod


function z = isprime(x)

  % this will give True/False/None
  %z = elementwise_op ('lambda x: x.is_prime', x);
  %z = uniop_bool_helper(x, 'lambda x: x.is_prime', 'sym');

  sf = { 'def sf(x):'
         '    r = x.is_prime'
         '    if r is None:'
         '        raise AttributeError("isprime: cannot determine if input is prime")'
         '    return r' };

  z = uniop_bool_helper(x, sf);

end


%!assert (isprime (sym(5)))
%!assert (~isprime (sym(4)))
%!assert (~isprime (sym(0)))
%!assert (~isprime (sym(1)))

%!test
%! a = [5 7 6; 1 2 337];
%! assert (isequal (isprime (a), [true true false; false true true]))

%!assert (~isprime(sym(-4)))
%!assert (~isprime(sym(4i)))
%!assert (~isprime(sym(3)/5))

%!error <cannot determine>
%! isprime(sym('x'));
