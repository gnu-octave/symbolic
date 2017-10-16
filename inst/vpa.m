%% Copyright (C) 2014-2017 Colin B. Macdonald
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
%% @defun  vpa (@var{x})
%% @defunx vpa (@var{x}, @var{n})
%% Create a variable-precision floating point number.
%%
%% @var{x} can be a string, a sym or a double.  Example:
%% @example
%% @group
%% x = vpa('1/3', 32)
%%   @result{} x = (sym) 0.33333333333333333333333333333333
%% a = sym(1)/3;
%% x = vpa(a, 32)
%%   @result{} x = (sym) 0.33333333333333333333333333333333
%% @end group
%% @end example
%%
%% If @var{n} is omitted it defaults to the current value of
%% @code{digits()}.
%%
%% Be careful when creating a high-precision float from a
%% double as you will generally only get 15 digits:
%% @example
%% @group
%% vpa(1/3)
%%   @result{} (sym) 0.3333333333333333148296162...
%% vpa(sqrt(2));
%% ans^2
%%   @result{} (sym) 2.0000000000000002734323463...
%% @end group
%% @end example
%%
%% For the same reason, passing numbers with decimal points
%% may produce undesirable results:
%% @example
%% @group
%% vpa(0.1)
%%   @result{} (sym) 0.1000000000000000055511151...
%% @end group
%% @end example
%%
%% Instead, enclose the decimal number in a string:
%% @example
%% @group
%% vpa('0.1')
%%   @result{} (sym) 0.10000000000000000000000000000000
%% @end group
%% @end example
%%
%% Very simple expressions can also be enclosed in quotes:
%% @example
%% @group
%% vpa('sqrt(2)')
%%   @result{} (sym) 1.4142135623730950488016887242097
%% @end group
%% @end example
%%
%% But be careful as this can lead to unexpected behaviour, such as
%% low-precision results if the string contains decimal points:
%% @example
%% @group
%% vpa('cos(0.1)')
%%   @print{} warning: string expression with decimals is dangerous, see "help vpa"
%%   @result{} (sym) 0.995004165278025709540...
%% @end group
%% @end example
%%
%% Instead, it is preferrable to use @code{sym} or @code{vpa} on the
%% inner-most parts of your expression:
%% @example
%% @group
%% cos(vpa('0.1'))
%%   @result{} (sym) 0.99500416527802576609556198780387
%% vpa(cos(sym(1)/10))
%%   @result{} (sym) 0.99500416527802576609556198780387
%% @end group
%% @end example
%%
%% @seealso{sym, vpasolve, digits}
%% @end defun

function r = vpa(x, n)

  if (nargin == 1)
    n = digits();
  elseif (nargin ~= 2)
    print_usage ();
  end


  if (isa(x, 'sym'))
    cmd = {
        'x, n = _ins'
        'return sympy.N(x, n),' };
    r = python_cmd (cmd, x, n);
  elseif (ischar (x))
    isnum = ~isempty (regexp (x, '^[-+]*?\d*\.?\d*(e-?\d+)?$'));
    if (~isnum && ~isempty (strfind (x, '.')))
      warning ('OctSymPy:vpa:precisionloss', ...
               'string expression with decimals is dangerous, see "help vpa"')
    end
    if (strcmp (x, 'inf') || strcmp (x, 'Inf') || strcmp (x, '+inf') || ...
        strcmp (x, '+Inf'))
      x = 'S.Infinity';
    elseif (strcmp (x, '-inf') || strcmp (x, '-Inf'))
      x = '-S.Infinity';
    elseif (strcmp (x, 'I'))
      x = 'Symbol("I")';
    end
    % Want Float if its '2.3' but N if its 'sqrt(2)'
    cmd = {
        'x, n = _ins'
        'try:'
        '    return sympy.Float(x, n),'
        'except ValueError:'
        '    return sympy.N(x, n),' };
    r = python_cmd (cmd, x, n);
  elseif (isfloat (x) && ~isreal (x))
    r = vpa (real (x), n) + sym (1i)*vpa (imag (x), n);
  elseif (isfloat(x) && isscalar(x) == 1)
    if (isnan (x))
      x = 'S.NaN';
    elseif (isinf (x) && x < 0)
      x = '-S.Infinity';
    elseif (isinf (x))
      x = 'S.Infinity';
    elseif (isequal (x, pi))
      x = 'S.Pi';
    elseif (isequal (x, -pi))
      x = '-S.Pi';
    elseif (isequal (x, exp (1)))
      x = exp (sym (1));
    elseif (isequal (x, -exp (1)))
      x = -exp (sym (1));
    end
    cmd = {
      'x, n = _ins'
      'return sympy.N(x, n)' };
    r = python_cmd (cmd, x, n);
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
%! % if sym does sth special for e so should vpa
%! a = vpa(sym(exp(1)), 64);
%! b = vpa(exp(1), 64);
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

%!test
%! % 'i' and 'I' just make vars
%! a = vpa(sym(1i));
%! b = vpa('i');
%! c = vpa('I');
%! assert (~isequal (a, b))
%! assert (~isequal (a, c))

%!test
%! % inf/-inf do not become symbol('inf')
%! S = {'oo', '-oo', 'inf', 'Inf', '-inf', '+inf'};
%! for j = 1:length(S)
%!   a = vpa(S{j});
%!   b = vpa(sym(S{j}));
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
%! sa = sympy (a);
%! sb = sympy (b);
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

%!test
%! % big integers
%! a = int64(12345678);
%! a = a*a;
%! b = vpa(a);
%! c = vpa('152415765279684');
%! assert (isequal (b, c))

%!xtest
%! % big integers (workaround poor num2str, works in 4.0?)
%! a = int64(1234567891);  a = a*a;
%! b = vpa(a);
%! c = vpa('1524157877488187881');
%! assert (isequal (b, c))

%!warning <dangerous> vpa ('sqrt(2.0)');
