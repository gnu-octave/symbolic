%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{r} =} isprime (@var{n})
%% Return true if a symbolic number is prime.
%%
%% @seealso{nextprime}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = isprime(x)

  %sf = { 'def sf(x):' '    return x.is_prime' };

  % could just call uniop_helper but this way we can catch the errors

  sf = { 'def sf(x):' ...
         '    if not x.is_integer or not x.is_nonnegative:' ...
         '        raise NameError("isprime: input must be nonnegative integer")' ...
         '    r = x.is_prime' ...
         '    if r is None:' ...
         '        raise NameError("isprime: cannot determine if input is prime")' ...
         '    return r' };

  cmd = { sf '' ...
          '(x,) = _ins' ...
          'try:' ...
          '    if x.is_Matrix:' ...
          '        return (True, x.applyfunc(lambda a: sf(a)))' ...
          '    else:' ...
          '        return (True, sf(x))' ...
          'except NameError, e:' ...
          '    return (False, str(e))' ...
        };

  [r, z] = python_cmd (cmd, x);

  if (~r)
    error(z)
  end

  z = logical(z);

end


%!assert (isprime (sym(5)))
%!assert (~isprime (sym(4)))
%!assert (~isprime (sym(0)))
%!assert (~isprime (sym(1)))

%!test
%! a = [5 7 6; 1 2 337];
%! assert (isequal (isprime (a), [true true false; false true true]))

%!error <must be nonnegative> isprime(sym(-4))
%!error <must be nonnegative> isprime(sym(4i))
%!error <must be nonnegative> isprime(sym(3)/5)
%!error <must be nonnegative> isprime(sym('x'))
%!error <cannot determine>
%! syms x positive
%! x = assumeAlso(x, 'integer');
%! isprime(x)
