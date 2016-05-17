%% Copyright (C) 2003 Willem J. Atsma
%% Copyright (C) 2014-2016 Colin B. Macdonald
%%
%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3, or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied
%% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%% PURPOSE.  See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.  If not,
%% see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defun  poly2sym (@var{c})
%% @defunx poly2sym (@var{c}, @var{x})
%% Create a symbolic polynomial expression from coefficients.
%%
%% If @var{x} is not specified, the free variable is set to @code{sym('x')}. @var{c}
%% may be a vector of doubles or syms. It can also be a cell array vector.
%% @var{x} may be a symbolic expression or something that converts to one.
%% The coefficients correspond to decreasing exponent of the free variable.
%%
%% Example:
%% @example
%% @group
%% x = sym ('x');
%% y = sym ('y');
%% poly2sym ([2 5])
%%   @result{} (sym) 2⋅x + 5
%% poly2sym (@{2*y 5 -3@}, x)
%%   @result{} (sym)
%%          2
%%       2⋅x ⋅y + 5⋅x - 3
%% @end group
%% @end example
%%
%% @seealso{@@sym/sym2poly, polyval, roots}
%% @end defun

function p = poly2sym(c,x)

  if (nargin == 1)
    x = sym('x');
  elseif (nargin == 2)
    x = sym(x);
  else
    print_usage ();
  end

  N = length(c);

  if (~iscell(c))
    tmp = c;
    c = {};
    for i=1:N
      % Bug #17
      %c{i} = tmp(i)
      idx.type = '()';
      idx.subs = {i};
      c{i} = subsref(tmp, idx);
    end
  end

  p = sym(0);
  for i=1:N
    % horner form
    %p = p*x+c{i};
    % monomial form (this is what matlab SMT does)
    p = p + c{i} * x^(N-i);
  end

end


%!shared x,y,a,b,c,p
%! syms x y a b c
%! p = x^3 + 2*x^2 + 3*x + 4;
%!assert(isAlways(  poly2sym([1 2 3 4]) == p  ))
%!assert(isAlways(  poly2sym([1 2 3 4],x) == p  ))
%!assert(isAlways(  poly2sym([1 2 3 4],y) == subs(p,x,y) ))
%!assert(isAlways(  poly2sym([1 2 3 4],5) == subs(p,x,5) ))
%!assert(isequal(  poly2sym ([1]),  1  ))
%!assert(isequal(  poly2sym ([]),  0  ))
%% symbolic coefficents
%!assert(isAlways(  poly2sym(sym([1 2 3 4]),x) == p  ))
%!assert(isAlways(  poly2sym([a b c],x) == a*x^2 + b*x + c  ))
%!assert(isAlways(  poly2sym([a b c]) == a*x^2 + b*x + c  ))
%!assert(isequal(  poly2sym(sym([])),  0  ))
%% cell arrays
%!assert(isAlways(  poly2sym({sym(1) sym(2)}, x) == x + 2  ))
%!assert(isequal(  poly2sym ({1}),  1  ))
%!assert(isequal(  poly2sym ({}),  0  ))
%!assert(isequal(  poly2sym ({1}, x),  1  ))
%!assert(isequal(  poly2sym ({}, x),  0  ))
%% weird cases (matlab SMT does this too, I think it should be an error)
%!assert(isAlways(  poly2sym([x x], x) == x^2 + x  ))

%!test
%! % mixed cell array with doubles and syms
%! assert (isequal (poly2sym ({2.0 sym(3) int64(4)}), 2*x^2 + 3*x + 4))

%!test
%! % string for x
%! p = poly2sym ([1 2], 's');
%! syms s
%! assert (isequal (p, s + 2))
