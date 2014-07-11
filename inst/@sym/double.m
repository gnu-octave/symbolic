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

  cmd = [ '(x,) = _ins\n' ...
          '# special case for zoo, FIXME: good idea?\n' ...
          'if x == zoo:\n' ...
          '    return (1,float(sp.oo),0.0)\n' ...
          'try:\n' ...
          '    z = float(x)\n'  ...
          'except TypeError:\n' ...
          '    flag = 0\n' ...
          'else:\n' ...
          '    flag = 1;\n' ...
          '    return (flag,z,0.0)\n' ...
          'if (flag == 0):\n' ...
          '    try:\n' ...
          '        z = complex(x)\n'  ...
          '    except TypeError:\n' ...
          '        flag = 0\n' ...
          '    else:\n' ...
          '        flag = 2;\n' ...
          '        return (flag,z.real,z.imag)\n' ...
          'return (0,0.0,0.0)' ];

  [flag, A, B] = python_cmd (cmd, x);

  assert(isnumeric(flag))
  assert(isnumeric(A))
  assert(isnumeric(B))

  if (flag==0)
    if (failerr)
      error('cannot convert to double');
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


%!assert (double (sym(10)) == 10)
%!assert (isequal (double (sym([10 12])), [10 12]))

%!test
%! assert (isempty (double (sym('x'), false)))
%! assert (isempty (double (sym([10 12 sym('x')]), false)))

%!test
%! %% complex
%! a = 3 + 4i;
%! b = sym(a);
%! assert (isequal (double (b), a))
%! assert (isequal (double (b/pi), a/pi))  % really?
