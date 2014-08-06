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
%% @deftypefn {Function File} {@var{y} =} not (@var{x})
%% Logical not of a symbolic array.
%%
%% @seealso{eq, ne, logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = not(x)

  % not same thing
  %y = ~logical(x);

  cmd = [ '(p,) = _ins\n' ...
          'def scalar_case(p,):\n' ...
          '    TE = TypeError("cannot logically negate sym \"%s\"" % str(p))\n' ...
          '    if p is S.true:\n' ...
          '        return S.false\n' ...
          '    if p is S.false:\n' ...
          '        return S.true\n' ...
          '    elif isinstance(p, Eq):\n' ...
          '        return Ne(p.lhs, p.rhs)\n' ...
          '    elif isinstance(p, Ne):\n' ...
          '        return Eq(p.lhs, p.rhs)\n' ...
          '    elif isinstance(p, Lt):\n' ...
          '        return Ge(p.lts, p.gts)\n' ...
          '    elif isinstance(p, Le):\n' ...
          '        return Gt(p.lts, p.gts)\n' ...
          '    elif isinstance(p, Gt):\n' ...
          '        return Le(p.gts, p.lts)\n' ...
          '    elif isinstance(p, Ge):\n' ...
          '        return Lt(p.gts, p.lts)\n' ...
          '    elif p is nan:\n' ...
          '        raise TE\n' ...
          '    elif p.is_number:\n' ...
          '        return S(not bool(p))\n' ...
          '    else:\n' ...
          '        raise TE\n' ...
          'try:\n' ...
          '    if p.is_Matrix:\n' ...
          '        r = p.applyfunc(lambda a: scalar_case(a))\n' ...
          '    else:\n' ...
          '        r = scalar_case(p)\n' ...
          '    flag = True\n' ...
          'except TypeError, e:\n' ...
          '    r = str(e)\n' ...
          '    flag = False\n' ...
          'return (flag, r)' ];

  [flag, r] = python_cmd (cmd, x);
  if (~flag)
    assert (ischar (r), '<not>: programming error?')
    error(['<not>: ' r])
  end
end


%!shared t, f
%! t = sym(true);
%! f = sym(false);

%!test
%! % simple
%! assert (isequal( ~t, f))
%! assert (isequal( ~t, f))

%!test
%! % array
%! w = [t t f t];
%! z = [f f t f];
%! assert (isequal( ~w, z))

%!test
%! % number
%! assert (isequal( ~sym(5), f))
%! assert (isequal( ~sym(0), t))

%!test
%! % output is sym
%! syms x
%! assert (isa (~(x == 4), 'sym'))

%!xtest
%! % output is sym even for scalar t/f
%! % ₣IXME: should match other bool fcns
%! assert (isa (~t, 'sym'))

%!test
%! % symbol ineq
%! syms x
%! a = [t  f  x == 1  x ~= 2  x < 3   x <= 4  x > 5   x >= 6];
%! b = [f  t  x ~= 1  x == 2  x >= 3  x > 4   x <= 5  x < 6];
%! assert (isequal( ~a, b))

%!test
%! % symbol ineq
%! syms x
%! try
%!   y = ~x
%!   waserr = false;
%! catch
%!   waserr = true;
%! end
%! assert (waserr)

