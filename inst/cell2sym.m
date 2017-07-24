%% Copyright (C) 2016 Lagu
%% Copyright (C) 2017 Colin B. Macdonald
%%
%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3, or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied
%% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%% PURPOSE.  See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.  If not,
%% see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defun @@sym cell2sym (@var{x})
%% Convert cell array to symbolic array.
%%
%% Examples:
%% @example
%% @group
%% cell2sym(@{'x', 'y'@})
%%   @result{} ans = (sym) [x  y]  (1×2 matrix)
%% @end group
%% @end example
%%
%% @example
%% @group
%% cell2sym(@{'x', 2; pi 'y'@})
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡x  2⎤
%%       ⎢    ⎥
%%       ⎣π  y⎦
%% @end group
%% @end example
%% @seealso{sym, syms}
%% @end defun

function c = cell2sym(p)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif (nargin == 2)
    error('Flag not supported yet');
  end

  s = size(p);
  c = sym([]);

  %% FIXME: Don't support multi-dimensional yet.
  assert (length (s) == 2)

  for i=1:s(1)
    for j=1:s(2)
      c(i, j) = p{i, j};
    end
  end

end


%!test
%! A = {1 2 3; 4 5 6};
%! B = [1 2 3; 4 5 6];
%! assert (isequal (cell2sym(A), sym(B)))

%!test
%! A = {'a' 'b'; 'c' 10};
%! B = [sym('a') sym('b'); sym('c') sym(10)];
%! assert (isequal (cell2sym(A), B))
