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
%% @defmethod  @@sym isAlways (@var{eq})
%% @defmethodx @@sym isAlways (@var{eq}, 'Unknown', 'false')
%% @defmethodx @@sym isAlways (@var{eq}, 'Unknown', 'true')
%% @defmethodx @@sym isAlways (@var{eq}, 'Unknown', 'error')
%% Test if expression is mathematically true.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% isAlways(x*(1+y) == x+x*y)
%%   @result{} 1
%% @end group
%% @end example
%% Contrast this with a test for “structural equality“:
%% @example
%% @group
%% logical(x*(1+y) == x+x*y)
%%   @result{} 0
%% @end group
%% @end example
%%
%% The optional keyword argument @qcode{'Unknown'} specifies that happens
%% for expressions that cannot simplify.  By default these return
%% false (that is, cannot verify it is always true).  Pass the
%% strings @qcode{'true'}, @qcode{'false'} or @qcode{'error'} to change the behaviour.  You
%% can also pass logical true/false.
%%
%% If @code{isAlways} is called on expressions without relationals,
%% it will return true for non-zero numbers:
%% @example
%% @group
%% isAlways (sym (10))
%%   @result{} 1
%% @end group
%% @end example
%%
%% It is safe to use @code{isAlways} even when the expression does not
%% require simplifying:
%% @example
%% syms x
%% isAlways (sin(x) - sin(x) == 0)
%%   @result{} 1
%% @end example
%% In practice, @code{isAlways} might get called on a simple
%% boolean variable, so this package implements @code{@@logical/isAlways}
%% (which is essentially a no-op).
%%
%% @seealso{@@sym/logical, @@sym/isequal, @@sym/eq, @@logical/isAlways}
%% @end defmethod


function r = isAlways(p, varargin)

  if (~ ((nargin == 1) || (nargin == 3)))
    print_usage ();
  end

  if (nargin == 3)
    assert(strcmpi(varargin{1}, 'unknown'))
    cant = varargin{2};
    if islogical(cant)
      % SMT doesn't allow nonstring but it seems reasonable
    elseif strcmpi(cant, 'true')
      cant = true;
    elseif strcmpi(cant, 'false')
      cant = false;
    elseif strcmpi(cant, 'error')
      % no-op
    else
      error('isAlways: invalid argument for "unknown" keyword')
    end
  else
    cant = false;
  end

  cmd = {
    'def simplify_tfn(p):'
    '    if p in (S.true, S.false):'
    '        return bool(p)'
    '    r = simplify(p)'
    '    #FIXME; Boolean, simplify more than once?'
    '    if r in (S.true, S.false):'
    '        return bool(r)'
    '    # FIXME: hopefully we get sympy patched for some of this'
    '    #ver = sympy.__version__'
    '    #if ver == "0.7.5" or ver.startswith("0.7.6") or ver.startswith("0.7.7"):'
    '    if True:'
    '        if isinstance(p, Equality):'
    '            r = Eq(sp.simplify(p.lhs - p.rhs), 0)'
    '            r = simplify(r)'
    '            if r in (S.true, S.false):'
    '                 return bool(r)'
    '        if isinstance(p, Unequality):'
    '            r = Eq(sp.simplify(p.lhs - p.rhs), 0)'
    '            r = simplify(r)'
    '            if r in (S.true, S.false):'
    '                 return not bool(r)'
    '        if isinstance(p, (Lt, Gt, Le, Ge)):'
    '            r = p._eval_relation(sp.simplify(p.lhs - p.rhs), 0)'
    '            r = simplify(r)'
    '            if r in (S.true, S.false):'
    '                 return not bool(r)'
    '    # for SMT compat'
    '    if p.is_number:'
    '        r = p.is_zero'  % FIXME: return bool(r)?
    '        if r in (S.true, S.false):'
    '            return not bool(r)'
    '    return None' };
  % could distinguish b/w None and return a string for this last case

  cmd = vertcat(cmd, {
    '(x, unknown) = _ins'
    'if x is not None and x.is_Matrix:'
    '    r = [a for a in x.T]' % note transpose
    'else:'
    '    r = [x,]'
    'r = [simplify_tfn(a) for a in r]'
    'r = [unknown if a is None else a for a in r]'
    'flag = True'
    'if r.count("error") > 0:'
    '    flag = False'
    '    r = "cannot reliably convert sym to bool"'
    'return (flag, r)' });

  [flag, r] = pycall_sympy__ (cmd, p, cant);

  if (~flag)
    assert (ischar (r), 'isAlways: programming error?')
    error(['isAlways: ' r])
  end

  r = cell2mat(r);
  r = reshape(r, size(p));

end


%!test
%! % basics
%! assert(isAlways(true))
%! assert(isAlways(1==1))
%! assert(isAlways(sym(1)==sym(1)))
%! assert(isAlways(sym(1)==1))

%!test
%! % numbers to logic?
%! assert (isAlways(sym(1)))
%! assert (isAlways(sym(-1)))
%! assert (~isAlways(sym(0)))

%!shared x
%! syms x

%!test
%! % in this case it is boolean
%! expr = x - x == 0;
%! assert (logical(expr))
%! assert (isAlways(expr))
%! % and both are logical type
%! assert (islogical(logical(expr)))
%! assert (islogical(isAlways(expr)))

%!test
%! % structurally same and mathematically true
%! % (here expr should be sym, non-boolean)
%! expr = x == x;
%! assert (logical(expr))
%! assert (isAlways(expr))
%! %assert (~islogical(expr))   % FIXME: Issue #56
%! %assert (isa(expr, 'sym))

%!test
%! % structurally same and mathematically true
%! % (here expr should be sym, non-boolean)
%! expr = 1 + x == x + 1;
%! assert (logical(expr))
%! assert (isAlways(expr))

%!test
%! % non-zero numbers are true
%! assert (isAlways(sym(1)))
%! assert (isAlways(sym(-10)))
%! assert (~isAlways(sym(0)))

% FIXME: should we support implicit == 0 like sympy?  SMT does oppositve, plus it ignores assumptions?  SMT behaviour is probably meant to mimic matlab doubles,
%expr = x - x;
%c=c+1; r(c) = logical(expr);
%c=c+1; r(c) = isAlways(expr);


%!shared x, y
%! syms x y

%!test
%! % structurally same and mathematically true
%! % (here expr should be sym, non-boolean)
%! expr = x*(1+y) == x*(y+1);
%! assert (logical(expr))
%! assert (isAlways(expr))
%! assert (islogical(isAlways(expr)))

%!test
%! % Now for some differences
%! % simplest example from SymPy FAQ
%! expr = x*(1+y) == x+x*y;
%! assert (~logical(expr))
%! assert (isAlways(expr))

%!test
%! % more differences 1, these don't simplify in sympy (as of 2016-01)
%! expr = (x+1)^2 == x*x + 2*x + 1;
%! assert (~logical(expr))
%! assert (isAlways(expr))

%!test
%! % more differences 2
%! expr = sin(2*x) == 2*sin(x)*cos(x);
%! assert (~logical(expr))
%! assert (isAlways(expr))

%!test
%! % more differences 3, false
%! expr =  x*(x+y) == x^2 + x*y + 1;
%! assert (~logical(expr))
%! assert (~isAlways(expr))
%! assert (~isAlways(expr, 'unknown', 'error'))

%!test
%! % logically not equal, math equal
%! exprn =  x*(x+y) ~= x^2 + x*y;
%! assert (logical(exprn))
%! assert (~isAlways(exprn))
%!test
%! % logically not equal, math not equal
%! exprn =  x*(x+y) ~= x^2 + x*y + 1;
%! assert (logical(exprn))
%! assert (isAlways(exprn))

%!test
%! % equal and not equal
%! e1 = sin(x)^2 + cos(x)^2 == 1;
%! e2 = sin(x)^2 + cos(x)^2 == 2;
%! assert (~logical(e1))
%! assert (isAlways(e1))
%! assert (~logical(e2))
%! assert (~isAlways(e2))
%! assert (~isAlways(e2, 'unknown', 'error'))

%!error <invalid argument .* keyword> isAlways(x, 'unknown', 'kevin')
%!error <Invalid call> isAlways(x, 'unknown')
%!error <assert .* failed> isAlways(x, 'kevin', 'true')

%!error <isAlways: cannot reliably convert sym to bool>
%! a = [x*(x+y)==x^2+x*y  x==y];
%! b = isAlways(a, 'unknown', 'error');

%!error <isAlways: cannot reliably convert sym to bool>
%! a = x==y;
%! b = isAlways(a, 'unknown', 'error');

%!test
%! % array, unknown keyword
%! a = [x==x x==x+1 x==y x*(x+y)==x^2+x*y cos(x)^2+sin(x)^2==2];
%! b = isAlways(a, 'unknown', false);
%! c = isAlways(a, 'unknown', 'false');
%! expect = [true false false true false];
%! assert (islogical(b))
%! assert (isequal (b, expect))
%! assert (isequal (c, expect))
%! b = isAlways(a, 'unknown', true);
%! c = isAlways(a, 'unknown', 'true');
%! expect = [true false true true false];
%! assert (islogical(b))
%! assert (isequal (b, expect))
%! assert (isequal (c, expect))

%!test
%! % ineq
%! e =  x*(x+y) >= x^2 + x*y + 1;
%! assert (~logical(e))
%! assert (isAlways(e))
%! e =  x*(x+y) <= x^2 + x*y;
%! assert (~logical(e))
%! assert (isAlways(e))

%test
% % FIXME; booleans
% e1 = x*(x+1) == x*x+x
% e2 = x*(x+1)+2 == x*x+x+2
% b = e1 & e2
% assert isAlways(b)
