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

%% -- Loadable Function: Y = any (X)
%%     "any" for symbolic arrays
%%
%%     Similar behaviour to the built-in any.
%%
%%     Throws an error if any entries are non-numeric.


%% Tests
%!shared a,s
%! a=[0 0; 1 0];
%! s=sym(a);
%!assert (isequal (any (s), any (a)))
%!assert (isequal (any (s,1), any (a,1)))
%!assert (isequal (any (s,2), any (a,2)))
%
%!shared a,s
%! a=[0 1 0];
%! s=sym(a);
%!assert (isequal (any (s), any (a)))
%!assert (isequal (any (s,1), any (a,1)))
%!assert (isequal (any (s,2), any (a,2)))
%
%!shared a,s,x
%! syms x
%! s=sym([0 1 x]);
%!test
%! try
%!   any(s)
%!   error('should fail with symbols')
%! catch
%! end


function z = any(x, varargin)

  z = double (x, false);
  if (isempty (z))
    error('indeterminable')
  else
    z = any (z, varargin{:});
  end
