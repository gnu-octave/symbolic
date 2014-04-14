## Copyright (C) 2003 Willem J. Atsma <watsma@users.sf.net>
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation;
## either version 3, or (at your option) any later version.
##
## This software is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public
## License along with this software; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{p} =} poly2sym (@var{c}, @var{x})
## Creates a symbolic polynomial expression @var{p} with coefficients @var{c}.
## If @var{p} is not specified, the free variable is set to sym("x"). @var{c}
## may be a vector or a cell-array of symbols. @var{x} may be a symbolic
## expression or a string.
## The coefficients correspond to decreasing exponent of the free variable.
##
## Example:
## @example
## symbols
## x = sym("x");
## y = sym("y");
## p = poly2sym ([2,5,-3]);         # p = 2*x^2+5*x-3
## c = poly2sym (@{2*y,5,-3@},x);     # p = 2*y*x^2+5*x-3
## @end example
##
## @seealso{sym2poly,polyval,roots}
## @end deftypefn

function p = poly2sym(c,x)

  if exist("x")!=1
    x = sym("x");
  endif

  N = length(c);

  if !iscell(c)
    tmp = c;
    c = cell;
    for i=1:N
      c(i) = tmp(i);
    endfor
  endif

  # we don't have vpa yet
  #p = vpa(0);
  p = sym(0);
  for i=1:N
    #if isnumeric(c{i})
    #  p = p*x+vpa(c{i});
    #else
      p = p*x+c{i};
    #endif
  endfor

endfunction
