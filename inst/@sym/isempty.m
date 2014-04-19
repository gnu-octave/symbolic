%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -- Loadable Function: isempty (X)
%%     Does a symbolic array have size 0 x 0
%%

function r = isempty(x)

  d = size(x);
  % Octave can have n x 0 and 0 x m empty arrays
  %r = isequal(d, [0 0]);
  r = prod(d) == 0;

end


%% Tests
%!shared se, a
%! se = sym ([]);
%! a = sym ([1 2]);
%!assert (~isempty (sym (1)))
%!assert (isempty (sym (se)))
%!assert (isempty (se == []))
%
%% FIXME: need slicing and subindex, Bug #14
%  xtest assert (isempty (a([])))
%  xtest assert (isempty (a([se])))
%
%% Growing an empty symfun into a scalar
%!test se(1) = 10;
%!test assert ( isa (se, 'sym'))
%!test assert ( isequal (se, 10))
