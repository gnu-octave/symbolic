%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {@var{z} =} plus (@var{x}, @var{y})
%% Add two symbolic expressions together (+).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = plus(x, y)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = plus(x, y);
    return
  end

  z = binop_helper(x, y, 'lambda x, y: x + y');

end


%!test
%! % basic addition
%! syms x
%! assert (isa (x+5, 'sym'))
%! assert (isa (5+x, 'sym'))
%! assert (isa (5+sym(4), 'sym'))
%! assert (isequal (5+sym(4), sym(9)))

%!test
%! % array addition
%! syms x
%! D = [0 1; 2 3];
%! A = [sym(0) 1; sym(2) 3];
%! DZ = D - D;
%! assert( isequal ( A + D , 2*D ))
%! assert( isequal ( D + A , 2*D ))
%! assert( isequal ( A + A , 2*D ))
%! assert( isequal ( A + 2 , D + 2 ))
%! assert( isequal ( 4 + A , 4 + D ))
