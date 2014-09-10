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
%% @deftypefn  {Function File} {@var{y} =} double (@var{x})
%% @deftypefnx {Function File} {@var{y} =} double (@var{x}, false)
%% Convert symbolic to doubles.
%%
%% Example:
%% @example
%% x = sym(1) / 3
%% double (x)
%% @end example
%%
%% Despite the name, this is how you get convert a complex sym to
%% floating point too:
%% @example
%% z = sym(4i) + 3;
%% double (z)
%% @end example
%%
%% If conversion fails, you get an error:
%% @example
%% syms x
%% double (x)
%% @end example
%%
%% You can pass an optional second argument of @code{false} to
%% return an empty array if conversion fails on any component.
%%
%% Example:
%% @example
%% syms x
%% a = [1 2 x];
%% b = double (a, false)
%% isempty (b)
%% @end example
%%
%% @seealso{sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = double(x, failerr)

  if (nargin == 1)
    failerr = true;
  end

  % FIXME: port to uniop?

  if ~(isscalar(x))
    % sympy N() works fine on matrices but it gives objects like "Matrix([[1.0,2.0]])"
    y = zeros(size(x));
    for j = 1:numel(x)
      % temp = x(j)  (Issue #17)
      idx.type = '()';
      idx.subs = {j};
      temp = double(subsref(x,idx), failerr);
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
          '    return (1, float(sp.oo), 0.0)' ...
          'try:' ...
          '    z = float(x)'  ...
          'except TypeError:' ...
          '    flag = 0' ...
          'else:' ...
          '    flag = 1;' ...
          '    return (flag, z, 0.0)' ...
          'if flag == 0:' ...
          '    try:' ...
          '        z = complex(x)'  ...
          '    except TypeError:' ...
          '        flag = 0' ...
          '    else:' ...
          '        flag = 2;' ...
          '        return (flag, z.real, z.imag)' ...
          'return (0, 0.0, 0.0)' };

  [flag, A, B] = python_cmd (cmd, x);

  assert(isnumeric(flag))
  assert(isnumeric(A))
  assert(isnumeric(B))

  if (flag==0)
    if (failerr)
      error('OctSymPy:double:conversion', 'cannot convert to double');
    else
      y = [];
    end
  elseif (flag==1)
    y = A;
  elseif (flag==2)
    y = A + 1i*B;
  else
    error('whut?');
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
%! % optional second argument to return empty on failure
%! assert (isempty (double (sym('x'), false)))
%! assert (isempty (double (sym([10 12 sym('x')]), false)))

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
%!error <cannot convert> syms x; double(x)
%!error <cannot convert> syms x; double([1 2 x])
