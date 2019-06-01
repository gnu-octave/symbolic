%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym isequaln (@var{f}, @var{g})
%% @defmethodx @@sym isequaln (@var{f}, @var{g}, @dots{})
%% Test if contents of arrays are equal, even with nan.
%%
%% Here NaN's are considered equal:
%% @example
%% @group
%% syms x
%% snan = sym(nan);
%% isequaln([1 snan x], [1 snan x])
%%   @result{} 1
%% @end group
%% @end example
%% To get the usual NaN convention, @pxref{isequal}.
%%
%% @seealso{@@sym/isequal, @@sym/logical, @@sym/isAlways, @@sym/eq}
%% @end defmethod

function t = isequaln(x, y, varargin)

  if (nargin < 2)
    print_usage ();
  end

  % isequal does not care about type, but if you wanted it to...
  %if ( ~ ( isa (x, 'sym') && isa (y, 'sym')))
  %  t = false;
  %  return
  %end

  %% some special cases
  if ~(is_same_shape(x, y))
    t = false;
    return
  end

  % In symy, nan == nan is true by structural (not mathematical)
  % equivalence, so we don't need to detect it ourselves.
  % Sympy's == returns a scalar for arrays, no special case.

  cmd = 'return (_ins[0] == _ins[1],)';

  t = pycall_sympy__ (cmd, sym(x), sym(y));

  if (~ islogical(t))
    error('nonboolean return from python');
  end

  if (nargin >= 3)
    t = t && isequaln(x, varargin{:});
  end

end


%!test
%! a = sym([1 2]);
%! b = a;
%! assert (isequaln (a, b))
%! b(1) = 42;
%! assert (~isequaln (a, b))

%!test
%! a = sym([1 2; 3 4]);
%! b = a;
%! assert (isequaln (a, b))
%! b(1) = 42;
%! assert (~isequaln (a, b))

%!test
%! a = sym([nan; 2]);
%! b = a;
%! assert (isequaln (a, b))

%!test
%! a = sym([nan 2; 3 4]);
%! b = a;
%! assert (isequaln (a, b))

%!test
%! % more than two arrays
%! a = sym([nan 2 3]);
%! b = a;
%! c = a;
%! assert (isequaln (a, b, c))
%! c(1) = 42;
%! assert (~isequaln (a, b, c))
