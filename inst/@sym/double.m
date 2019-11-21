%% Copyright (C) 2014-2017, 2019 Colin B. Macdonald
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
%% @defmethod @@sym double (@var{x})
%% Convert symbolic to doubles.
%%
%% Example:
%% @example
%% @group
%% x = sym(1) / 3
%%   @result{} x = (sym) 1/3
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% double (x)
%%   @result{} ans =  0.3333
%% @end group
%% @end example
%%
%% Despite the name, this is one way to convert a complex sym to
%% floating point:
%% @example
%% @group
%% z = sym(4i) - 3;
%% double (z)
%%   @result{} ans = -3 + 4i
%% @end group
%% @end example
%%
%% If conversion fails, you get an error:
%% @example
%% @group
%% syms x
%% double (x)
%%   @print{} ??? ... can't convert expression ...
%% @end group
%% @end example
%%
%% @seealso{sym, vpa}
%% @end defmethod


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

  cmd = { '(x,) = _ins'
          'if x == zoo:'  % zoo -> Inf + Infi
          '    return (float(sp.oo), float(sp.oo))'
          'if x == nan:'
          '    return (float(nan), 0.0)'
          'x = complex(x)'
          'return (x.real, x.imag)'
        };

  [A, B] = pycall_sympy__ (cmd, x);

  %y = A + B*i;  % not quite the same for Inf + InFi
  if (B == 0.0)
    y = A;
  else
    y = complex(A, B);
  end

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
%! oo = sym(inf);
%! assert( double(oo) == inf )
%! assert( double(-oo) == -inf )
%! assert( isnan(double(0*oo)) )

%!test
%! zoo = sym('zoo');
%! assert (double(zoo) == complex(inf, inf))

%!test
%! zoo = sym('zoo');
%! assert (double(-zoo) == double(zoo) )
%! assert( isnan(double(0*zoo)) )

%!test
%! % nan
%! snan = sym(nan);
%! assert( isnan(double(snan)))

%!test
%! % don't want NaN+NaNi
%! snan = sym(nan);
%! assert (isreal (double (snan)))

%!test
%! % arrays
%! a = [1 2; 3 4];
%! assert( isequal(  double(sym(a)), a  ))
%! assert( isequal(  double(sym(a)), a  ))

%! % should fail with error for non-double
%!error <TypeError> syms x; double(x)
%!error <TypeError> syms x; double([1 2 x])
