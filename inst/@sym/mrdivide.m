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
%% @deftypefn  {Function File}  {@var{z} =} mrdivide (@var{x}, @var{y})
%% Forward slash division of symbolic expressions (/).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mrdivide(x, y)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = mrdivide(x, y);
    return
  end

  z = python_cmd ('return _ins[0]/_ins[1],', sym(x), sym(y));

end


%!test
%! % scalar
%! syms x
%! assert (isa( x/x, 'sym'))
%! assert (isequal( x/x, sym(1)))
%! assert (isa( 2/x, 'sym'))
%! assert (isa( x/2, 'sym'))

%!test
%! % matrix / scalar
%! D = 2*[0 1; 2 3];
%! A = sym(D);
%! assert (isequal ( A/2 , D/2  ))
%! assert (isequal ( A/sym(2) , D/2  ))
