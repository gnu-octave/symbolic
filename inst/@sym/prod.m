%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{y} =} prod (@var{x})
%% @deftypefnx {Function File} {@var{y} =} prod (@var{x}, @var{n})
%% Product of symbolic expressions.
%%
%% Example:
%% @example
%% @group
%% syms x y z
%% f = prod([x y z])
%%    @result{} x*y*z
%% @end group
%% @end example
%%
%% Can specify row or column sums using @var{n}:
%% @example
%% @group
%% f = prod([x y; x z], 1)
%%    @result{}
%%       ⎡ 2     ⎤
%%       ⎣x   y⋅z⎦
%% f = prod([x y; x z], 2)
%%    @result{}
%%       ⎡x⋅y⎤
%%       ⎢   ⎥
%%       ⎣x⋅z⎦
%% @end group
%% @end example
%%
%% @seealso{sum, symprod}
%% @end deftypefn

function y = prod(x, n)

  if (isscalar(x))
    y = x;
    return
  end

  if (nargin == 1)
    if (isrow(x))
      n = 2;
    elseif (iscolumn(x))
      n = 1;
    else
      n = 1;
    end
  end

  x = sym(x);
  n = double(n);

  %y = python_cmd ({'return sp.prod(_ins[0]),'}, x);
  cmd = { 'A = _ins[0]'
          'B = sp.Matrix.zeros(A.rows, 1)'
          'for i in range(0, A.rows):'
          '   B[i] = prod(A.row(i))'
          'return B,' };
  if (n == 1)
    y = python_cmd (cmd, transpose(x));
    y = transpose(y);
  elseif (n == 2)
    y = python_cmd (cmd, x);
  else
    error('unsupported');
  end
end


%!shared x,y,z
%! syms x y z
%!assert (isequal (prod (x), x))
%!assert (isequal (prod ([x y z]), x*y*z))
%!assert (isequal (prod ([x; y; z]), x*y*z))
%!assert (isequal (prod ([x y z], 1), [x y z]))
%!assert (isequal (prod ([x y z], 2), x*y*z))

%!shared a,b
%! b = [1 2; 3 4]; a = sym(b);
%!assert (isequal (prod(a), prod(b)))
%!assert (isequal (prod(a,1), prod(b,1)))
%!assert (isequal (prod(a,2), prod(b,2)))
