%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym logical (@var{eq})
%% Test if expression is "structurally" true.
%%
%% This should probably be used with if/else flow control.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% logical(x*(1+y) == x*(y+1))
%%   @result{} 1
%% logical(x == y)
%%   @result{} 0
%% @end group
%% @end example
%%
%% Note this is different from @code{isAlways} which tries to
%% determine mathematical truth:
%% @example
%% @group
%% isAlways(x*(1+y) == x+x*y)
%%   @result{} 1
%% logical(x*(1+y) == x+x*y)
%%   @result{} 0
%% @end group
%% @end example
%%
%% Sometimes we end up with a symbolic logical values; @code{logical}
%% can convert these to native logical values:
%% @example
%% @group
%% sym(true)
%%   @result{} ans = (sym) True
%% logical(ans)
%%   @result{} ans = 1
%% @end group
%% @end example
%%
%% @code{logical} treats objects according to:
%% @itemize
%% @item @code{@@logical} true/false: as is.
%% @item symbolic logical true/false: convert to true/false.
%% @item equalities (==), unequalities (~=): check for structural
%% equivalence (whether lhs and rhs match without simplifying.)
%% @item numbers: true if nonzero, false if zero.
%% @item nan, oo, zoo: FIXME
%% @item boolean expr: And, Or: FIXME
%% @item other objects raise error.
%% @end itemize
%%
%% @seealso{@@sym/isAlways, @@sym/isequal, @@sym/eq}
%% @end defmethod


function r = logical(p)

  % do not simplify here

  cmd = {
    'def scalar2tfn(p):'
    '    if p in (S.true, S.false):'
    '        return bool(p)'
    '    # ineq nothing to do, but Eq, Ne check structural eq'
    '    if isinstance(p, Eq):'
    '        r = p.lhs == p.rhs'  % could not be true from Eq ctor
    '        return bool(r)'  % none -> false
    '    if isinstance(p, Ne):'
    '        r = p.lhs != p.rhs'
    '        return bool(r)'
    '    if isinstance(p, (Lt, Gt, Le, Ge)):'
    '        return False'  % didn't reduce in ctor, needs isAlways
    '    # for SMT compat'
    '    if p.is_number:'
    '        r = p.is_zero'  % FIXME: return bool(r)?
    '        if r in (S.true, S.false):'
    '            return not bool(r)'
    '    return None'
    '    #return "cannot reliably convert sym \"%s\" to bool" % str(p))'
  };

  cmd = vertcat(cmd, {
    '(x, unknown) = _ins'
    'if x is not None and x.is_Matrix:'
    '    r = [a for a in x.T]'  % note transpose
    'else:'
    '    r = [x,]'
    'r = [scalar2tfn(a) for a in r]'
    'r = [unknown if a is None else a for a in r]'
    'flag = True'
    'if r.count("error") > 0:'
    '    flag = False'
    '    r = "cannot reliably convert sym to bool"'
    'return (flag, r)' });

  [flag, r] = pycall_sympy__ (cmd, p, 'error');

  % FIXME: oo, zoo error too in SMT
  %        '    elif p is nan:'
  %        '        raise TE   # FIXME: check SMT'


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

%!test
%! % numbers to logic?
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
%! e = e';
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
%! syms x
%! logical(x);

%!error <cannot .* convert sym .* bool>
%! logical(sym(nan))

%!test
%! % but oo and zoo are non-zero so we call those true
%! % (SMT errors on these)  FIXME
%! syms oo zoo
%! assert (logical (oo))
%! % assert (logical (zoo))

%%!xtest
%%! % FIXME: what about positive x?
%%! syms x positive
%%! w = logical(x);
%%! assert (w)

%!test
%! % older Octave (< 4.2) didn't automatically do "if (logical(obj))"
%! e = sym(true);
%! if (e)
%!   assert(true);
%! else
%!   assert(false);
%! end

%!test
%! % more of above
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
