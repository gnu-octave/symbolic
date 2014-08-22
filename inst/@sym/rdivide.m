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
%% @deftypefn  {Function File}  {@var{z} =} rdivide (@var{x}, @var{y})
%% Elementwise forward slash division of sym expressions (dot slash).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = rdivide(x, y)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:42735-workaround', ...
            'worked around octave bug #42735')
    z = rdivide(x, y);
    return
  end


  cmd = [ '(x,y) = _ins\n'  ...
          'if x.is_Matrix and y.is_Matrix:\n'  ...
          '    return ( x.multiply_elementwise(y.applyfunc(lambda a: 1/a)) ,)\n' ...
          'if not x.is_Matrix and y.is_Matrix:\n'  ...
          '    return ( y.applyfunc(lambda a: x/a) ,)\n' ...
          'else:\n' ...
          '    return ( x/y ,)' ];

  z = python_cmd (cmd, sym(x), sym(y));

end


%!test
%! % scalar
%! syms x
%! assert (isa (x ./ 1, 'sym'))
%! assert (isa (x ./ x, 'sym'))
%! assert (isequal (x ./ 1, x))
%! assert (isequal (x ./ x, sym(1)))

%!test
%! % matrix-scalar
%! D = 2*[0 1; 2 3];
%! A = sym(D);
%! assert (isequal ( A./2 , D/2  ))
%! assert (isequal ( A./sym(2) , D/2  ))
%! assert (isequal ( D./sym(2) , D/2  ))

%!test
%! % matrix ./ matrix
%! D = [1 2; 3 4];
%! A = sym(D);
%! assert (isequal ( A./A , D./D  ))
%! assert (isequal ( A./D , D./D  ))
%! assert (isequal ( D./A , D./D  ))

%!test
%! % matrix ./ matrix with symbols
%! syms x y
%! A = [x y; x^2 2*y];
%! B = [y x; x y];
%! assert (isequal ( A./A , sym(ones(2,2)) ))
%! assert (isequal ( A./B , [x/y y/x; x 2] ))

%!test
%! % scalar ./ matrix
%! D = [1 2; 3 4];
%! A = sym(D);
%! assert (isequal ( 12./A , 12./D  ))
