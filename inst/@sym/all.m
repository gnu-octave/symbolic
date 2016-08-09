%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @documentencoding UTF-8
%% @defmethod  @@sym all (@var{x})
%% @defmethodx @@sym all (@var{x}, @var{dim})
%% Return true if all entries of a symbolic vector are nonzero.
%%
%% Similar behaviour to the built-in @code{all} with regard to
%% matrices and the second argument.
%%
%% Throws an error if any entries are non-numeric.
%%
%% Example:
%% @example
%% @group
%% all([sym(1) pi 3])
%%   @result{} ans = 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/any}
%% @end defmethod


function z = all(x, varargin)

  if (nargin > 2)
    print_usage ();
  end

  z = all (logical (x), varargin{:});

  %z = double (x, false);
  %if (isempty (z))
  %  error ('indeterminable')
  %else
  %  z = all (z, varargin{:});
  %end

end


%!test
%! % matrix
%! a = [0 3; 1 2];
%! s = sym (a);
%! assert (isequal (all (s), all (a)))
%! assert (isequal (all (s,1), all (a,1)))
%! assert (isequal (all (s,2), all (a,2)))

%!test
%! % vector
%! a = [1 2 3];
%! s = sym (a);
%! assert (isequal (all (s), all (a)))
%! assert (isequal (all (s,1), all (a,1)))
%! assert (isequal (all (s,2), all (a,2)))

%!test
%! % should fail on symbols
%! syms x
%! s = [1 2 x];
%! try
%!   all (s)
%!   waserr = false;
%! catch
%!   waserr = true;
%! end
%! assert (waserr)
