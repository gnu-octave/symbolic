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
%% @deftypefn  {Function File} {@var{z} =} norm (@var{x})
%% @deftypefnx {Function File} {@var{z} =} norm (@var{x}, @var{ord})
%% Symbolic vector/matrix norm.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = norm(x, ord)

  if (nargin < 2)
    ord = 'meh';
    line1 = 'x = _ins[0]\nord = None\n';
  else
    line1 = '(x,ord,) = _ins\n';
  end

  if (ischar(ord))
    if (~strcmp(ord, 'fro') && ~strcmp(ord, 'meh'))
      error('invalid norm')
    end
  else
    ord = sym(ord);
  end

  cmd = [ line1 ...
          'if x.is_Matrix:\n' ...
          '    return ( x.norm(ord) ,)\n' ...
          'else:\n' ...
          '    return ( sqrt(x**2) ,)' ];

  z = python_cmd_string (cmd, sym(x), ord);

end


%!assert (isequal (norm(sym(-6)), 6))

%!test
%! syms x y real
%! assert (isequal (norm([x 1; 3 y]), sqrt(x^2 + y^2 + 10)))
%! assert (isequal (norm([x 1; 3 y], 'fro'), sqrt(x^2 + y^2 + 10)))
%! assert (isequal (norm([x 1], 2), sqrt(x^2 + 1)))

%! % test sym vs double ord
%!test
%! syms x
%! assert (isequal (norm([x 2 1], 1), abs(x) + 3))
%! assert (isequal (norm([x 2 1], sym(1)), abs(x) + 3))
%! assert (isequal (norm([sym(-3) 2 1], inf), sym(3)))
%! assert (isequal (norm([sym(-3) 2 1], sym(inf)), sym(3)))

