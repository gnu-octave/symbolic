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
          '    TE = TypeError("cannot reliably convert sym \"%s\" to bool" % str(p))\n' ...
          '    if p in (S.true, S.false):\n' ...
          '        return bool(p)\n' ...
          '    elif isinstance(p, sp.relational.Relational):\n' ...
          '        return bool(p._eval_relation(p.lhs, p.rhs))\n' ...
          '    elif p is nan:\n' ...
          '        raise TE\n' ...
          '    elif p.is_number:\n' ...
          '        return bool(p)\n' ...
          '    else:\n' ...
          '        #return bool(p)\n' ...
          '        #return False\n' ...
          '        raise TE\n' ...
          'try:\n' ...
          '    if p.is_Matrix:\n' ...
          '        # we want a pure python list .applyfunc gives Matrix back\n' ...
          '        r = [scalar_case(a) for a in p.T]\n' ...
          '    else:\n' ...
          '        r = [scalar_case(p)]\n' ...
          '    flag = True\n' ...
          'except TypeError, e:\n' ...
          '    r = str(e)\n' ...
          '    flag = False\n' ...
          'return (flag, r)' ];

  [flag, r] = python_cmd_string (cmd, p);
  if (~flag)
    assert (ischar (r), 'logical: programming error?')
    error(['logical: ' r])
  end
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

%!error <cannot .* convert sym .* bool>
%! syms x oo
%! logical(x);

%!error <cannot .* convert sym .* bool>
%! logical(sym(nan))

%!test
%! % but oo and zoo are non-zero so we call those true
%! % (SMT errors on these)
%! syms oo zoo
%! assert (logical (oo))
%! assert (logical (zoo))

%%!xtest
%%! % FIXME: what about positive x?
%%! syms x positive
%%! w = logical(x);
%%! assert (w)

%!xtest
%! % FIXME: bug in Octave: if should automatically use logical
%! % (want "if (obj)" same as "if (logical(obj))")
%! e = sym(true);
%! if (e)
%!   assert(true);
%! else
%!   assert(false);
%! end

% more above, one it passes
% e2 = sym(1) == sym(1);
% if (e2)
%   assert(true);
% else
%   assert(false);
% end
% e3 = sym([1 2]) == sym([1 1]);
% if (e3(1))
%   assert(true);
% else
%   assert(false);
% end
