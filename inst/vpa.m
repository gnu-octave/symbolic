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

  if (nargin == 1)
    n = digits();
  end


  if (isa(x, 'sym'))
    cmd = {
        'x, n = _ins'
        'return sympy.N(x, n),' };
    r = python_cmd (cmd, x, n);
  elseif (ischar(x))
    x = magic_str_str(x);
    % Want Float if its '2.3' but N if its 'pi'
    cmd = {
        'x, n = _ins'
        'try:'
        '    return sympy.Float(x, n),'
        'except ValueError:'
        '    pass'
        'return sympy.N(x, n),' };
    r = python_cmd (cmd, x, n);
  elseif (isfloat(x) && ~isreal (x))
    r = vpa(real(x),  n) + sym('I')*vpa(imag(x), n);
  elseif (isfloat(x) && isscalar(x) == 1)
    [s, flag] = magic_double_str(x);
    if (flag)
      r = vpa(s, n);
    else
      cmd = {
          'x, n = _ins'
          'return sympy.Float(x, n),' };
      r = python_cmd (cmd, x, n);
    end
  elseif (isinteger(x) && isscalar(x) == 1)
    cmd = {
        'x, n = _ins'
        'return sympy.N(x, n),' };
    r = python_cmd (cmd, x, n);
  elseif (~isscalar(x))
    cmd = { sprintf('return sympy.ZeroMatrix(%d, %d).as_mutable(),', size(x)) };
    r = python_cmd (cmd);
    for i=1:numel(x)
      r(i) = vpa(x(i), n);
    end
  else
    x
    class(x)
    error('conversion to vpa with those arguments not (yet) supported');
  end


end


%!test
%! a = vpa(0, 4);
%! b = double(a);
%! assert(b == 0)

%!test
%! a = vpa(pi, 4);
%! b = sin(a);
%! assert(abs(double(b)) < 1e-4)

%!test
%! % vpa from double is ok, doesn't warn (c.f., sym(2.3))
%! a = vpa(2.3);
%! assert(true)

%!test
%! % vpa from double not more than 16 digits
%! a = vpa(sqrt(pi), 32);
%! b = sin(a^2);
%! assert(abs(double(b)) > 1e-20)
%! assert(abs(double(b)) < 1e-15)

%!test
%! a = vpa(sym(pi), 32);
%! b = sin(a);
%! assert(abs(double(b)) < 1e-30)

%!test
%! a = vpa(sym(pi), 256);
%! b = sin(a);
%! assert(abs(double(b)) < 1e-256)

%!test
%! % pi str
%! a = vpa('pi', 32);
%! b = sin(a);
%! assert(abs(double(b)) < 1e-32)

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
%! % integer type
%! a = vpa(int32(6), 64);
%! b = vpa(6, 64);
%! assert (isequal (a, b))

%!test
%! % matrix of int
%! b = int32([pi 0; 6.25 1]);
%! c = vpa(b, 6);
%! assert (isequal (double(c), [3 0; 6 1]))

%!test
%! % can pass pi directly to vpa
%! a = vpa(sym(pi), 128);
%! b = vpa(pi, 128);
%! assert (isequal (a, b))

%!test
%! % can pass pi directly to vpa, even in array
%! a = vpa(sym([2 pi]), 128);
%! b = vpa([2 pi], 128);
%! assert (isequal (a, b))

%!test
%! % can pass i directly to vpa
%! a = vpa(sym(i));
%! b = vpa(i);
%! c = vpa('i');
%! d = vpa('I');
%! assert (isequal (a, b))
%! assert (isequal (a, c))
%! assert (isequal (a, d))

%!test
%! % inf/-inf do not become symbol('inf')
%! S = {'oo', '-oo', 'inf', 'Inf', '-inf', '+inf'};
%! for i = 1:length(S)
%!   a = vpa(S{i});
%!   b = vpa(sym(S{i}));
%!   assert (isequal (a, b))
%! end

%!test
%! a = vpa('2.3', 20);
%! s = strtrim(disp(a, 'flat'));
%! assert (strcmp (s, '2.3000000000000000000'))

%!test
%! % these should *not* be the same
%! a = vpa(2.3, 40);
%! b = vpa('2.3', 40);
%! sa = char(a);
%! sb = char(b);
%! assert (~isequal (a, b))
%! assert (abs(double(a - b)) > 1e-20)
%! assert (abs(double(a - b)) < 1e-15)
%! assert (~strcmp(sa, sb))

%!test
%! % these should *not* be the same
%! x = vpa('1/3', 32);
%! y = vpa(sym(1)/3, 32);
%! z = vpa(1/3, 32);
%! assert (isequal (x, y))
%! assert (~isequal (x, z))
