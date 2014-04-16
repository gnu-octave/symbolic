%% Copyright (C) 2003 Willem J. Atsma <watsma@users.sf.net>
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
%% @deftypefn {Function File} {@var{p} =} poly2sym (@var{c}, @var{x})
%% Creates a symbolic polynomial expression @var{p} with coefficients @var{c}.
%%
%% If @var{x} is not specified, the free variable is set to sym('x'). @var{c}
%% may be a vector of doubles or syms. It can also be a cell array vector.
%% @var{x} may be a symbolic expression or something that converts to one.
%% The coefficients correspond to decreasing exponent of the free variable.
%%
%% Example:
%% @example
%% x = sym ('x');
%% y = sym ('y');
%% p = poly2sym ([2 5 -3]);        % p = 2*x^2 + 5*x - 3
%% p = poly2sym (@{2*y 5 -3@},x);    % p = 2*y*x^2 + 5*x - 3
%% @end example
%%
%% @seealso{sym2poly,polyval,roots}
%% @end deftypefn

function p = poly2sym(c,x)

  if (nargin == 1)
    x = sym('x');
  else
    x = sym(x);
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

  % we don't have vpa yet
  %p = vpa(0);
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
