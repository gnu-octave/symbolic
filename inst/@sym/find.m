%% Copyright (C) 2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} find (@var{x})
%% @deftypemethodx @@sym {} find (@var{x}, @var{n})
%% @deftypemethodx @@sym {} find (@var{x}, @var{n}, @var{dir})
%% @deftypemethodx @@sym {[@var{i}, @var{j}] =} find (@dots{})
%% @deftypemethodx @@sym {[@var{i}, @var{j}, @var{v}] =} find (@dots{})
%% Find non-zero or true entries of a symbolic matrix.
%%
%% Example:
%% @example
%% @group
%% syms x y positive
%% find ([0 x 0 y])
%%   @result{}
%%       2  4
%% @end group
%% @end example
%%
%% Note its enough that an expression @emph{could} be non-zero:
%% @example
%% @group
%% syms x y
%% find ([x 0 0 1 x+y])
%%   @result{}
%%       1  4  5
%% @end group
%% @end example
%%
%% For matrices containing equalities, inequalities and boolean
%% expressions, @code{find} looks for @code{True} (but does not
%% simplify):
%% @example
%% @group
%% syms x y
%% A = [x == x; or(x == y, x*(y+1) >= x*y+x); x^2-y^2 == (x-y)*(x+y)]
%%   @result{} A = (sym 3×1 matrix)
%%       ⎡           True            ⎤
%%       ⎢                           ⎥
%%       ⎢x = y ∨ x⋅(y + 1) ≥ x⋅y + x⎥
%%       ⎢                           ⎥
%%       ⎢  2    2                   ⎥
%%       ⎣ x  - y  = (x - y)⋅(x + y) ⎦
%%
%% find (A)
%%   @result{}
%%       1
%% @end group
%%
%% @group
%% find (simplify (A))
%%   @result{}
%%       1
%%       2
%%       3
%% @end group
%% @end example
%%
%% @seealso{find, @@sym/logical, @@sym/isAlways}
%% @end deftypemethod


function [i, j, v] = find(x, varargin)

  if (nargin > 3)
    print_usage ();
  end

  if (nargout <= 1)
    i = find (mylogical (x), varargin{1:end});
  elseif (nargout == 2)
    [i, j] = find (mylogical (x), varargin{1:end});
  elseif (nargout == 3)
    [i, j] = find (mylogical (x), varargin{1:end});
    sz = size (i);
    v = zeros (sym (sz(1)), sz(2));
    for n=1:numel(i)
      % issue #17:  v(n) = x(i(n), j(n));
      idx.type = '()';
      idx.subs = {i(n), j(n)};
      tmp = subsref(x, idx);
      idx.type = '()';
      idx.subs = {n};
      v = subsasgn(v, idx, tmp);
    end
  else
    print_usage ();
  end

end


function r = mylogical(p)
% helper function, similar to "logical"
% The difference is that expressions like "x+y" don't raise
% errors and instead return "true" (that is, generally nonzero).

  % FIXME: could check if every entry is boolean, equality, inequality, etc
  % return all([s is None or isinstance(s, bool) or s.is_Boolean or s.is_Relational for s in x])
  % And if so, call "logical".

  cmd = {
    'def scalar2tf(x):'
    '    if x is None or isinstance(x, bool):'
    '        return bool(x)'
    '    if x.is_Boolean or x.is_Relational:'
    '        if x.doit() in (S.true, True):'
    '            return True'
    '        return False'
    '    try:'
    '        r = bool(x)'
    '    except TypeError:'
    '        r = False'
    '    return r'
    '#'
    'x, = _ins'
    'if x is not None and x.is_Matrix:'
    '    x = [a for a in x.T]'  % note transpose
    'else:'
    '    x = [x,]'
    'return [scalar2tf(a) for a in x],' };

  r = pycall_sympy__ (cmd, p);
  r = cell2mat(r);
  r = reshape(r, size(p));
end


%!error <Invalid> find (sym (1), 2, 3, 4)
%!error <Invalid> [x, y, z, w] = find (sym (1))

%!test
%! syms x y positive
%! assert (isequal (find ([0 x 0 y]), [2 4]))
%! assert (isequal (find ([0 x 0 y], 1), 2))
%! assert (isequal (find ([0 x 0 y], 1, 'first'), 2))
%! assert (isequal (find ([0 x 0 y], 1, 'last'), 4))
%! assert (isequal (find ([0 x 0 y], 2, 'last'), [2 4]))

%!test
%! % its enough that it could be non-zero, does not have to be
%! syms x y
%! assert (isequal (find ([0 x+y]), 2))

%!test
%! % false should not be found
%! syms x y
%! assert (isequal (find ([x==x x==y]), 1))
%! assert (isequal (find ([x==y]), []))

%!test
%! % and/or should be treated as boolean
%! syms x y
%! assert (isequal (find ([or(x==y, x==2*y) x==y x==x]), 3))

%!test
%! % None
%! none = pycall_sympy__ ('return None');
%! assert (isequal (find ([sym(0) none sym(1)]), 3))
%! syms x y
%! assert (isequal (find ([x==y  none  x==x]), 3))

%!test
%! % two output
%! syms x y
%! A = [x 0 0; x+y 5 0];
%! [i, j] = find (A);
%! assert (isequal (i, [1; 2; 2]))
%! assert (isequal (j, [1; 1; 2]))

%!test
%! % three output
%! syms x y
%! A = [x 0 0; x+y 5 0];
%! [i, j, v] = find (A);
%! assert (isequal (i, [1; 2; 2]))
%! assert (isequal (j, [1; 1; 2]))
%! assert (isequal (v, [x; x+y; sym(5)]))
