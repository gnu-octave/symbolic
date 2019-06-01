%% Copyright (C) 2014-2019 Colin B. Macdonald
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
%% @defmethod  @@sym diff (@var{f})
%% @defmethodx @@sym diff (@var{f}, @var{x})
%% @defmethodx @@sym diff (@var{f}, @var{x}, @var{x}, @dots{})
%% @defmethodx @@sym diff (@var{f}, @var{x}, @var{n})
%% @defmethodx @@sym diff (@var{f}, @var{x}, @var{y})
%% @defmethodx @@sym diff (@var{f}, @var{x}, @var{x}, @var{y}, @var{y}, @dots{})
%% @defmethodx @@sym diff (@var{f}, @var{x}, @var{n}, @var{y}, @var{m}, @dots{})
%% Symbolic differentiation.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% f = sin (cos (x));
%% diff (f)
%%   @result{} (sym) -sin(x)⋅cos(cos(x))
%% diff (f, x)
%%   @result{} (sym) -sin(x)⋅cos(cos(x))
%% simplify (diff (f, x, x))
%%   @result{} (sym)
%%            2
%%       - sin (x)⋅sin(cos(x)) - cos(x)⋅cos(cos(x))
%% @end group
%% @end example
%%
%% Partial differentiation:
%% @example
%% @group
%% syms x y
%% f = cos(2*x + 3*y);
%% diff(f, x, y, x)
%%   @result{} (sym) 12⋅sin(2⋅x + 3⋅y)
%% diff(f, x, 2, y, 3)
%%   @result{} (sym) -108⋅sin(2⋅x + 3⋅y)
%% @end group
%% @end example
%%
%% Other examples:
%% @example
%% @group
%% diff(sym(1))
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% Partial derivatives are assumed to commute:
%% @example
%% @group
%% syms f(x, y)
%% diff(f, x, y)
%%   @result{} ans(x, y) = (symfun)
%%
%%          2
%%         ∂
%%       ─────(f(x, y))
%%       ∂y ∂x
%% @end group
%%
%% @group
%% diff(f, y, x)
%%   @result{} ans(x, y) = (symfun)
%%
%%          2
%%         ∂
%%       ─────(f(x, y))
%%       ∂y ∂x
%% @end group
%% @end example
%%
%% @seealso{@@sym/int}
%% @end defmethod


function z = diff(f, varargin)

  % simpler version, but gives error on differentiating a constant
  %cmd = 'return sp.diff(*_ins),';

  %% some special cases for SMT compat.
  % FIXME: with a sympy symvar, could move this to python?
  if (nargin == 1)  % diff(f) -> symvar
    x = symvar(f, 1);
    if (isempty(x))
      x = sym('x');  % e.g., diff(sym(6))
    end
    z = diff(f, x);
    return
  else
    q = varargin{1};
    % Note: access sympy srepr to avoid double() overhead for common diff(f,x)
    isnum2 = isnumeric (q) || (isa (q, 'sym') && strncmpi (sympy (q), 'Integer', 7));
    if ((nargin == 2) && isnum2)  % diff(f,2) -> symvar
      x = symvar(f, 1);
      if (isempty(x))
        x = sym('x');   % e.g., diff(sym(6), 2)
      end
      z = diff(f, x, varargin{1});
      return
    end
    if ((nargin == 3) && isnum2)  % diff(f,2,x) -> diff(f,x,2)
      z = diff(f, varargin{2}, varargin{1});
      return
    end
  end


  cmd = { 'f = _ins[0]'
          'args = _ins[1:]'
          'return f.diff(*args),' };

  for i = 1:length(varargin)
    varargin{i} = sym(varargin{i});
  end
  z = pycall_sympy__ (cmd, sym(f), varargin{:});

end


%!shared x,y,z
%! syms x y z

%!test
%! % basic
%! assert(logical( diff(sin(x)) - cos(x) == 0 ))
%! assert(logical( diff(sin(x),x) - cos(x) == 0 ))
%! assert(logical( diff(sin(x),x,x) + sin(x) == 0 ))

%!test
%! % these fail when doubles are not converted to sym
%! assert(logical( diff(sin(x),x,2) + sin(x) == 0 ))
%! assert(logical( diff(sym(1),x) == 0 ))
%! assert(logical( diff(1,x) == 0 ))
%! assert(logical( diff(pi,x) == 0 ))

%!test
%! % symbolic diff of const (w/o variable) fails in sympy, but we work around
%! assert (isequal (diff(sym(1)), sym(0)))

%!test
%! % nth symbolic diff of const
%! assert (isequal (diff(sym(1), 2), sym(0)))
%! assert (isequal (diff(sym(1), sym(1)), sym(0)))

%!test
%! % octave's vector difference still works
%! assert(isempty(diff(1)))
%! assert((diff([2 6]) == 4))

%!test
%! % other forms
%! f = sin(x);
%! g = diff(f,x,2);
%! assert (isequal (diff(f,2), g))
%! assert (isequal (diff(f,sym(2)), g))
%! g = diff(f,x);
%! assert (isequal (diff(f), g))
%! assert (isequal (diff(f,1), g))

%!test
%! % old SMT supported (still does?) the 'n' before the 'x'
%! % we might remove this someday, no longer seems documented in SMT
%! f = sin(x);
%! g = diff(f,x,2);
%! assert (isequal (diff(f,2,x), g))
%! assert (isequal (diff(f,sym(2),x), g))
%! g = diff(f,x);
%! assert (isequal (diff(f,1,x), g))

%!test
%! % matrix
%! A = [x sin(x); x*y 10];
%! B = [1 cos(x); y 0];
%! assert(isequal(diff(A,x),B))

%!test
%! % bug: use symvar
%! a = x*y;
%! b = diff(a);
%! assert (isequal (b, y))

%!test
%! % bug: symvar should be used on the matrix, not comp-by-comp
%! a = [x y x*x];
%! b = diff(a);
%! assert (~isequal (b(2), 1))
%! assert (isequal (b, [1 0 2*x]))
%! b = diff(a,1);
%! assert (~isequal (b(2), 1))
%! assert (isequal (b, [1 0 2*x]))
