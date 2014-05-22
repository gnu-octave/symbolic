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

  cmd = [ '(x,) = _ins\n'   ...
          'if x.is_Matrix:\n'   ...
          '    z = x.applyfunc(lambda a: sp.isprime(a))\n'  ...
          'else:\n'   ...
          '    z = sp.isprime(x)\n'  ...
          'return (z,)' ];

  z = python_cmd (cmd, x);

  %% postproccess to logical
  % FIXME: Issue #27
  % FIXME: but anyway, this is a bit horrid, not the recommended approach
  if (numel(z) > 1)
    tf = zeros(size(z), 'logical');
    for i=1:numel(z)
      %rhs = subsref(z, substruct('()', {i}))
      rhs = python_cmd ('return _ins[0][_ins[1]] == True,', z, i-1);
      tf(i) = rhs;
    end
    z = tf;
  end
end


%!assert (isprime (sym(5)))
%!assert (~isprime (sym(4)))
%!test
%! a = [5 7 6; 1 2 337];
%! assert (isequal (isprime (a), [true true false; false true true]))
