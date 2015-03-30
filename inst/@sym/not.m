%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{y} =} not (@var{x})
%% Logical not of a symbolic array.
%%
%% @seealso{eq, ne, logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = not(x)

  % not the same as:
  %y = ~logical(x);

  % FIXME: simpler version? don't micromanage sympy but gives ~x
  %  '    try:'
  %  '        return Not(p)'
  %  '    except:'
  %  '        raise TE'

  % cf., logical, isAlways

  cmd = {
    '(p,) = _ins'
    'def scalar_case(p,):'
    '    TE = TypeError("cannot logically negate sym \"%s\"" % str(p))'
    '    if sympy.__version__ == "0.7.5":' % later Not(p) below ok
    '        if isinstance(p, Eq): return Ne(p.lhs, p.rhs)'
    '        elif isinstance(p, Ne): return Eq(p.lhs, p.rhs)'
    '        elif isinstance(p, Lt): return Ge(p.lts, p.gts)'
    '        elif isinstance(p, Le): return Gt(p.lts, p.gts)'
    '        elif isinstance(p, Gt): return Le(p.gts, p.lts)'
    '        elif isinstance(p, Ge): return Lt(p.gts, p.lts)'
    '    if p is nan:'
    '        raise TE'  % FIXME: check SMT
    '    elif isinstance(p, (BooleanFunction, Relational)):'
    '        return Not(p)'
    '    elif p in (S.true, S.false):'
    '        return Not(p)'
    '    elif p.is_number:'
    '        return S(not bool(p))'
    '    else:'
    '        raise TE'
    'try:'
    '    if p.is_Matrix:'
    '        r = p.applyfunc(lambda a: scalar_case(a))'
    '    else:'
    '        r = scalar_case(p)'
    '    flag = True'
    'except TypeError as e:'
    '    r = str(e)'
    '    flag = False'
    'return (flag, r)' };

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
%! e = ~(x == 4);
%! assert (isa (e, 'sym'))
%! assert (strncmp(char(e), 'Unequality', 10))

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

