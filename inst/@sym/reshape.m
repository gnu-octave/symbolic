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
%% @deftypefn  {Function File} {@var{y} =} reshape (@var{x}, @var{n}, @var{m})
%% @deftypefnx {Function File} {@var{y} =} reshape (@var{x}, [@var{n}, @var{m}])
%% Change the shape of a symbolic array.
%%
%% @seealso{size}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function z = reshape(a, n, m)

  % reshaping a double array with sym sizes
  if ~(isa(a, 'sym'))
    if (nargin == 2)
      z = reshape(a, double(n));
    else
      z = reshape(a, double(n), double(m));
    end
    return
  end

  if (nargin == 2)
    m = n(2);
    n = n(1);
  end

  cmd = [ '(A,n,m) = _ins\n'  ...
          'if A.is_Matrix:\n'  ...
          '    #return ( A.reshape(n,m) ,)\n' ...
          '    #sympy is row-based\n' ...
          '    return ( A.T.reshape(m,n).T ,)\n' ...
          'else:\n' ...
          '    return ( A ,)' ];

  z = python_cmd_string(cmd, sym(a), int32(n), int32(m));

end


%!test
%! d = [2 4 6; 8 10 12];
%! a = sym(d);
%! assert (isequal (reshape(a, [1 6]), reshape(d, [1 6])))
%! assert (isequal (reshape(a, 1, 6), reshape(d, 1, 6)))
%! assert (isequal (reshape(a, 2, 3), reshape(d, 2, 3)))
%! assert (isequal (reshape(a, 3, 2), reshape(d, 3, 2)))
%! assert (isequal (reshape(a, 6, 1), reshape(d, 6, 1)))

%!shared x, a, d
%! syms x
%! a = [1 x^2 x^4; x x^3 x^5];
%! d = [0 2 4; 1 3 5];
%!
%!test
%! b = reshape(a, [1 6]);
%! assert (isequal (size(b), [1 6]))
%! assert (isequal (b, x.^reshape(d,1,6)))
%!
%!test
%! b = reshape(a, [6 1]);
%! assert (isequal (size(b), [6 1]))
%! assert (isequal (b, x.^reshape(d,6,1)))
%! b = reshape(b, size(a));
%! assert (isequal (size(b), [2 3]))
%! assert (isequal (b, a))
%!
%!test
%! b = a(:);
%! assert( isequal (size(b), [6 1]))
%! assert( isequal (b, x.^(d(:))))
%!
%!test
%! % reshape scalar
%! assert (logical( reshape(x, 1, 1) == x ))
%! assert (logical( reshape(x, [1 1]) == x ))
