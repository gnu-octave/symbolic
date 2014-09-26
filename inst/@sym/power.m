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
%% @deftypefn  {Function File}  {@var{z} =} power (@var{x}, @var{y})
%% Symbolic expression componentwise exponentiation (dot carat).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = power(x, y)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = power(x, y);
    return
  end


  cmd = { '(x,y) = _ins'
          'if x.is_Matrix and y.is_Matrix:'
          '    for i in range(0, len(x)):'
          '        x[i] = x[i]**y[i]'
          '    return x,'
          'if x.is_Matrix and not y.is_Matrix:'
          '    return x.applyfunc(lambda a: a**y),'
          'if not x.is_Matrix and y.is_Matrix:'
          '    return y.applyfunc(lambda a: x**a),'
          'else:'
          '    return x**y,' };

  z = python_cmd (cmd, sym(x), sym(y));

end


%!test
%! % scalar .^ scalar
%! syms x
%! assert (isa (x.^2, 'sym'))
%! assert (isa (2.^x, 'sym'))
%! assert (isa (x.^x, 'sym'))
%! assert (isequal (x.^2, x^2))
%! assert (isequal (2.^x, 2^x))
%! assert (isequal (x.^x, x^x))

%!test
%! % scalar .^ matrix
%! D = [0 1; 2 3];
%! A = sym(D);
%! assert (isequal ( sym(2).^D , 2.^D ))
%! assert (isequal ( sym(2).^A , 2.^A ))
%! assert (isequal ( 2.^D , 2.^A ))
%! assert (isequal ( 2.^A , 2.^A ))

%!test
%! % matrix .^ matrix
%! syms x
%! A = [x 2*x; 3*x 4*x];
%! D = [0 1; 2 3];
%! B = sym(D);
%! assert (isequal ( A.^D, [1 2*x; 9*x^2 64*x^3] ))
%! assert (isequal ( A.^B, [1 2*x; 9*x^2 64*x^3] ))

%!test
%! % matrix .^ scalar
%! syms x
%! A = [x 2*x];
%! assert (isequal ( A.^2,      [x^2 4*x^2] ))
%! assert (isequal ( A.^sym(2), [x^2 4*x^2] ))
