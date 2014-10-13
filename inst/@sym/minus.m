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
%% @deftypefn  {Function File}  {@var{z} =} minus (@var{x}, @var{y})
%% Subtract one symbolic expression from another (-).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = minus(x, y)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = minus(x, y);
    return
  end


  % -y + x
  z = axplusy(-1, y, x);

end

%!test
%! % scalar
%! syms x
%! assert (isa (x-1, 'sym'))
%! assert (isa (x-x, 'sym'))
%! assert (isequal (x-x, sym(0)))

%!test
%! % matrices
%! D = [0 1; 2 3];
%! A = sym(D);
%! DZ = D - D;
%! assert (isequal ( A - D , DZ  ))
%! assert (isequal ( A - A , DZ  ))
%! assert (isequal ( D - A , DZ  ))
%! assert (isequal ( A - 2 , D - 2  ))
%! assert (isequal ( 4 - A , 4 - D  ))
