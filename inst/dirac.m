## Copyright (C) 2006 Sylvain Pelissier <sylvain.pelissier@gmail.com>
## Copyright (C) 2015 Colin B. Macdonald <cbm@m.fsf.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{y} =} dirac (@var{x})
## Compute the Dirac delta (generalized) function.
##
## The Dirac delta "function" is a generalized function (or distribution)
## which is zero almost everywhere, except at the origin where it is
## infinite.
##
## Examples:
## @example
## @group
## dirac (0)
## @result{} Inf
## dirac (1)
## @result{} 0
## dirac ([-10 -1 0 1 inf])
## @result{} 0     0   Inf     0     0
## @end group
## @end example
## @seealso{heaviside}
## @end deftypefn

function y = dirac(x)
  if (nargin != 1)
    print_usage ();
  endif

  if (iscomplex (x))
    error ("dirac: X must not contain complex values");
  endif

  y = zeros (size (x), class (x));
  y(x == 0) = Inf;

  y(isnan (x)) = NaN;
endfunction


%!assert (isinf (dirac (0)))
%!assert (dirac (1) == 0)
%!assert (isnan (dirac (nan)))
%!assert (isequaln (dirac ([-1 1 0 eps inf -inf nan]), [0 0 inf 0 0 0 nan]))
%!error <complex values> dirac (1i)
%!assert (isa (dirac (single (0)), 'single'))
