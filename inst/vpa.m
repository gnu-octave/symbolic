%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{y} =} vpa (@var{x})
%% @deftypefnx {Function File} {@var{y} =} vpa (@var{x}, @var{n})
%% Create a variable precision floating point number.
%%
%% @var{x} can be a string, a sym or a double.  Example:
%% @example
%% x = vpa('1/3', 32)   # 32 digits 0.333...
%% a = sym(1)/3;
%% x = vpa(a, 32)       # same
%% x = vpa(1/3, 32)     # no!  first makes double 1/3 (15 digits)
%% @end example
%%
%% @seealso{sym, vpasolve}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = vpa(x, n)

  if (numel(x) ~= 1 && ~ischar(x) && ~isa(x, 'sym'))
    x = mat2list(x);
    cmd = {
      'L = _ins[0]'
      'o = _ins[1:]'
      'L = [[sympy.N(b, *o) for b in a] for a in L]'
      'return sympy.Matrix(L),' };
  else
    cmd = {
      'x = _ins[0]'
      'o = _ins[1:]'
      'return sympy.N(x, *o),' };
  end

  if (nargin == 1)
    r = python_cmd (cmd, x);
  else
    r = python_cmd (cmd, x, n);
  end

end


function Ac = mat2list(A)
%private helper
%   convert an array to a list of lists

  [n, m] = size(A);

  Ac = cell(n,1);
  for i=1:n
    Ac{i} = num2cell(A(i,:));
  end
end


%!test
%! a = vpa(0, 4);
%! b = double(a);
%! assert(b == 0)

%!test
%! a = vpa(pi, 4);
%! b = sin(a);
%! assert(abs(double(b) < 1e-4))

%!test
%! % vpa from double not more than 16 digits
%! a = vpa(pi, 32);
%! b = sin(a);
%! assert(abs(double(b) > 1e-20))
%! assert(abs(double(b) < 1e-15))

%!test
%! a = vpa(sym(pi), 32);
%! b = sin(a);
%! assert(abs(double(b) < 1e-30))

%!test
%! a = vpa(sym(pi), 256);
%! b = sin(a);
%! assert(abs(double(b) < 1e-256))

%!test
%! % pi str
%! a = vpa('pi', 32);
%! b = sin(a);
%! assert(abs(double(b) < 1e-32))

%!test
%! % pi str
%! a = vpa('pi', 32);
%! b = vpa(sym('pi'), 32);
%! assert (double (a - b) == 0)

%!test
%! spi = sym(pi);
%! a = vpa(spi, 10);
%! b = double(a);
%! assert(~isAlways(spi == a))

%!test
%! % matrix of sym
%! a = [sym(pi) 0; sym(1)/2 1];
%! b = [pi 0; 0.5 1];
%! c = vpa(a, 6);
%! assert(max(max(abs(double(c)-b))) < 1e-6)

%!test
%! % matrix of double
%! b = [pi 0; 0.5 1];
%! c = vpa(b, 6);
%! assert(max(max(abs(double(c)-b))) < 1e-6)

%!test
%! % matrix of int
%! b = int32([pi 0; 6.25 1]);
%! c = vpa(b, 6);
%! assert (isequal (double(c), [3 0; 6 1]))
