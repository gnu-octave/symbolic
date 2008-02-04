## Copyright (C) 2002 Ben Sapp
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} splot(@var{f},@var{x},@var{range})
## Plot a symbolic function f(x) over range.
## @end deftypefn

function splot(expression,symbol,range)
  ## we should be a little smarter about this
  t = linspace(min(range),max(range),400);
  x = zeros(size(t));
  j = 1;
  for i = t
    x(j) = to_double(subs(expression,symbol,vpa(t(j))));
    j++;
  endfor

  plot(t,x);
endfunction
