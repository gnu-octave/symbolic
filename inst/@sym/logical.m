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
%% @deftypefn {Function File} {@var{r} =} logical (@var{eq})
%% Test if expression is "structurally" true.
%%
%% This should probably be used with if/else flow control.
%%
%% Example:
%% @example
%% logical(x*(1+y) == x*(y+1))    % true
%% logical(x == y)    % false
%% @end example
%%
%% Note this is different from @code{isAlways}.
%% FIXME: doc better.
%%
%% Example:
%% @example
%% isAlways(x*(1+y) == x+x*y)    % true
%% logical(x*(1+y) == x+x*y)   % false!
%% @end example
%%
%% @seealso{isAlways, isequal, eq (==)}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = logical(p)

  cmd = [ '(p,) = _ins\n' ...
          'def scalar_case(p,):\n' ...
          '    if p in (S.true, S.false):\n' ...
          '        return bool(p)\n' ...
          '    if isinstance(p, sp.relational.Relational):\n' ...
          '        return bool(p._eval_relation(p.lhs, p.rhs))\n' ...
          '    if p.is_number:\n' ...
          '        return bool(p)\n' ...
          '    # FIXME: better list cases that are ok...\n' ...
          '    #return bool(p)\n' ...
          '    return False\n' ...
          'if p.is_Matrix:\n' ...
          '    # we want a pure python list .applyfunc gives Matrix back\n' ...
          '    r = [scalar_case(a) for a in p.T]\n' ...
          'else:\n' ...
          '    r = [scalar_case(p)]\n' ...
          'return (True, r, )' ];

  [flag, r] = python_cmd (cmd, p);
  assert(flag, 'FIXME: use this to support things we want to error out instead of T/F');
  r = cell2mat(r);
  r = reshape(r, size(p));

end


%!test
%! % basics, many others in isAlways.m
%! assert (logical(true))
%! assert (~(logical(false)))
%! assert (logical(sym(1)))
%! assert (logical(sym(-1)))
%! assert (~logical(sym(0)))

%!xtest
%! % logical(symbol): we adopt the conventiion these are true if nonzero
%! % SMT has error for these: FIXME: do we want this instead?
%! syms x oo
%! y1 = logical(x);
%! assert (islogical (y1))
%! assert (~y1)
%! y2 = logical(oo);
%! assert (islogical (y2))
%! assert (y2)

%!test
%! % eqns, "structurally equivalent"
%! syms x
%! e = logical(x == x);
%! assert ( islogical (e))
%! assert (e)
%! e = logical(x == 1);
%! assert ( islogical (e))
%! assert (~e)

%!test
%! % eqn could have solutions but are false in general
%! syms x
%! e = logical(x^2 == x);
%! assert ( islogical (e))
%! assert (~e)
%! e = logical(2*x == x);
%! assert ( islogical (e))
%! assert (~e)

%!test
%! % FIXME: (not sure yet)  T/F matrices should stay sym until logical()
%! a = sym(1);
%! e = a == a;
%! assert (isa (e, 'sym'))
%! assert (islogical (logical (e)))
%! e = [a == a  a == 0  a == a];
%! assert (isa (e, 'sym'))
%! assert (islogical (logical (e)))

%!test
%! % sym vectors of T/F to logical
%! a = sym(1);
%! e = [a == a  a == 0  a == a];
%! w = logical(e);
%! assert (islogical (w))
%! assert (isequal (w, [true false true]))
%! e = e.';   # FIXME: e' gave error
%! w = logical(e);
%! assert (islogical (w))
%! assert (isequal (w, [true; false; true]))

%!test
%! % sym matrix of T/F to logical
%! a = sym([1 2 3; 4 5 6]);
%! b = sym([1 2 0; 4 0 6]);
%! e = a == b;
%! w = logical(e);
%! assert (islogical (w))
%! assert (isequal (w, [true true false; true false true]))

%!xtest
%! % if-else-end blocks automatically use logical
%! % FIXME: bug in Octave?
%! e = sym(true);
%! if (e)   % want same as "if (logical(e))"
%!   assert(true);
%! else
%!   assert(false);
%! end
%! e2 = sym(1) == sym(1);
%! if (e2)
%!   assert(true);
%! else
%!   assert(false);
%! end
%! e3 = sym([1 2]) == sym([1 1]);
%! if (e3(1))
%!   assert(true);
%! else
%!   assert(false);
%! end
