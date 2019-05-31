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
%% @defmethod @@sym int (@var{f})
%% @defmethodx @@sym int (@var{f}, @var{x})
%% @defmethodx @@sym int (@var{f}, @var{x}, @var{a}, @var{b})
%% @defmethodx @@sym int (@var{f}, @var{x}, [@var{a}, @var{b}])
%% @defmethodx @@sym int (@var{f}, @var{a}, @var{b})
%% @defmethodx @@sym int (@var{f}, [@var{a}, @var{b}])
%% Symbolic integration.
%%
%% Definite integral:
%% @example
%% @group
%% syms x
%% f = x^2;
%% F = int(f, x, 1, 2)
%%   @result{} F = (sym) 7/3
%% @end group
%% @end example
%% or alternatively
%% @example
%% @group
%% F = int(f, x, [1 2])
%%   @result{} F = (sym) 7/3
%% @end group
%% @end example
%%
%% Indefinite integral:
%% @example
%% @group
%% F = int(f, x)
%%   @result{} F = (sym)
%%        3
%%       x
%%       ──
%%       3
%% F = int(f)
%%   @result{} F = (sym)
%%        3
%%       x
%%       ──
%%       3
%% @end group
%% @end example
%%
%% @seealso{@@sym/diff}
%% @end defmethod


function F = int(f, x, a, b)

  if (nargin == 4)
    % int(f, x, a, b)
    assert(numel(a)==1)
    assert(numel(b)==1)
    definite = true;


  elseif (nargin == 2) && (numel(x) == 1)
    % int(f, x)
    definite = false;


  elseif (nargin == 1)
    % int(f)
    definite = false;
    x = symvar(f,1);
    if isempty(x)
      x = sym('x');
    end


  elseif (nargin == 2) && (numel(x) == 2)
    % int(f, [a b])
    idx.type = '()';
    idx.subs = {2};
    definite = true;
    b = subsref(x, idx);
    idx.subs = {1};
    a = subsref(x, idx);

    x = symvar(f,1);
    if isempty(x)
      x = sym('x');
    end


  elseif (nargin == 3) && (numel(a) == 2)
    % int(f, x, [a b])
    definite = true;
    idx.type = '()';
    idx.subs = {2};
    b = subsref(a, idx);
    idx.subs = {1};
    a = subsref(a, idx);


  elseif (nargin == 3) && (numel(a) == 1)
    % int(f, a, b)
    definite = true;
    b = a;
    a = x;
    x = symvar(f,1);
    if isempty(x)
      x = sym('x');
    end


  else
    print_usage ();

  end


  %% now do the definite or indefinite integral
  if (definite)
    cmd = { '(f, x, a, b) = _ins'
            'F = sp.integrate(f, (x, a, b))'
            'return F,' };
    F = pycall_sympy__ (cmd, sym(f), sym(x), sym(a), sym(b));
  else
    cmd = { '(f,x) = _ins'
            'd = sp.integrate(f, x)'
            'return d,' };
    F = pycall_sympy__ (cmd, sym(f), sym(x));
  end

end


%!shared x,y,a
%! syms x y a
%!assert(logical(int(cos(x)) - sin(x) == 0))
%!assert(logical(int(cos(x),x) - sin(x) == 0))
%!assert(logical(int(cos(x),x,0,1) - sin(sym(1)) == 0))

%!test
%! %% limits might be syms
%! assert( isequal (int(cos(x),x,sym(0),sym(1)), sin(sym(1))))
%! assert( isequal (int(cos(x),x,0,a), sin(a)))

%!test
%! %% other variables present
%! assert( isequal (int(y*cos(x),x), y*sin(x)))

%!test
%! %% limits as array
%! assert( isequal (int(cos(x),x,[0 1]), sin(sym(1))))
%! assert( isequal (int(cos(x),x,sym([0 1])), sin(sym(1))))
%! assert( isequal (int(cos(x),x,[0 a]), sin(a)))

%!test
%! %% no x given
%! assert( isequal (int(cos(x),[0 1]), sin(sym(1))))
%! assert( isequal (int(cos(x),sym([0 1])), sin(sym(1))))
%! assert( isequal (int(cos(x),[0 a]), sin(a)))
%! assert( isequal (int(cos(x),0,a), sin(a)))

%!test
%! %% integration of const
%! assert( isequal (int(sym(2),y), 2*y))
%! assert( isequal (int(sym(2)), 2*x))
%! assert( isequal (int(sym(2),[0 a]), 2*a))
%! assert( isequal (int(sym(2),0,a), 2*a))

%!test
%! % componentwise int of array
%! A = [x x*x];
%! assert (isequal (int(A, x), [x^2/2 x^3/3]))

%!test
%! % NonElementaryIntegral bug
%! % https://savannah.gnu.org/bugs/index.php?46831
%! f = int(exp(exp(x)));
%! f = f + 2;
%! g = diff(f);
%! assert (isequal (g, exp(exp(x))))
