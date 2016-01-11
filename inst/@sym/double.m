%% Copyright (C) 2014, 2015, 2016 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{y} =} double (@var{x})
%% @deftypefnx {Function File} {@var{y} =} double (@var{x}, false)
%% Convert symbolic to doubles.
%%
%% Example:
%% @example
%% @group
%% >> x = sym(1) / 3
%%    @result{} x = (sym) 1/3
%% >> double (x)
%%    @result{} ans =  0.33333
%% @end group
%% @end example
%%
%% Despite the name, this is one way to convert a complex sym to
%% floating point:
%% @example
%% @group
%% >> z = sym(4i) - 3;
%% >> double (z)
%%    @result{} ans = -3 + 4i
%% @end group
%% @end example
%%
%% If conversion fails, you get an error:
%% @example
%% @group
%% >> syms x
%% >> double (x)
%%    @print{} ??? cannot convert to double
%% @end group
%% @end example
%%
%% You can pass an optional second argument of @code{false} to
%% return an empty array if conversion fails on any component.
%% For example:
%% @example
%% @group
%% >> syms x
%% >> a = [1 2 x];
%% >> b = double (a, false)
%%    @result{} b = [](0x0)
%% @end group
%% @end example
%%
%% @seealso{sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = double(x)

  % FIXME: port to uniop?

  if ~(isscalar(x))
    % sympy N() works fine on matrices but it gives objects like "Matrix([[1.0,2.0]])"
    y = zeros(size(x));
    for j = 1:numel(x)
      % temp = x(j)  (Issue #17)
      idx.type = '()';
      idx.subs = {j};
      temp = double(subsref(x,idx));
      if (isempty(temp))
        y = [];
        return
      end
      y(j) = temp;
    end
    return
  end

  cmd = { '(x,) = _ins' ...
          '# special case for zoo, FIXME: good idea?' ...
          'if x == zoo:' ...
          '    return (float(sp.oo), 0.0)' ...
          'x=complex(x)' ...
          'return (x.real, x.imag)'
        };

  [A, B] = python_cmd (cmd, x);

  y = A + B*i;

end

%!test
%! % numeric scalar
%! a = double(sym(10));
%! assert (a == 10)
%! assert (isa (a, 'double'))

%!test
%! % numeric vectors
%! a = double(sym([10 12]));
%! assert (isequal (a, [10 12]))
%! assert (isa (a, 'double'))

%!test
%! % complex
%! a = 3 + 4i;
%! b = sym(a);
%! assert (isequal (double (b), a))

%!xtest
%! % unexpected, precisely same floating point
%! a = 3 + 4i;
%! b = sym(a);
%! assert (isequal (double (b/pi), a/pi))

%!test
%! % floating point
%! x = sqrt(sym(2));
%! assert( abs(double(x) - sqrt(2)) < 2*eps)
%! x = sym(pi);
%! assert( abs(double(x) - pi) < 2*eps)

%!test
%! % various infinities
%! oo = sym(inf);
%! zoo = sym('zoo');
%! assert( double(oo) == inf )
%! assert( double(-oo) == -inf )
%! assert( double(zoo) == inf )
%! assert( double(-zoo) == inf )
%! assert( isnan(double(0*oo)) )
%! assert( isnan(double(0*zoo)) )

%!test
%! % nan
%! snan = sym(nan);
%! assert( isnan(double(snan)))

%!test
%! % arrays
%! a = [1 2; 3 4];
%! assert( isequal(  double(sym(a)), a  ))
%! assert( isequal(  double(sym(a)), a  ))

%! % should fail with error for non-double
%!error <TypeError> syms x; double(x)
%!error <TypeError> syms x; double([1 2 x])
