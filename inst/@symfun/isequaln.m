%% Copyright (C) 2017 NVS Abhilash
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
%% @defmethod  @@symfun isequaln (@var{f}, @var{g})
%% @defmethodx @@symfun isequaln (@var{f}, @var{g}, @dots{})
%% Test if contents of two or more arrays are equal, even with nan.
%%
%% Example:
%% @example
%% @group
%% syms x
%% f(x) = x + 1;
%% g(x) = x + 1;
%% isequaln(f, g)
%%   @result{} 1
%% @end group
%% @end example
%%
%% Note: two symfuns are equal if they have the same formula @emph{and}
%% same arguments:
%% @example
%% @group
%% syms x y
%% f(x) = x + 1;
%% g(x, y) = x + 1;
%% isequaln(f, g)
%%   @result{} 0
%% @end group
%% @end example
%%
%% Note: isequaln considers NaN's to be equal:
%% @example
%% @group
%% syms x y
%% f(x) = nan;
%% g(x) = nan;
%% isequaln(f, g)
%%   @result{} 1
%% @end group
%% @end example
%%
%% @seealso{@@symfun/isequal, @@sym/isequal, @@symfun/formula, @@symfun/argnames}
%% @end defmethod

function t = isequaln(x, y, varargin)

  if (nargin <= 1)
    print_usage ();
  end

  t = isequaln(formula(x), formula(y)) && isequal(argnames(x), argnames(y));

  if nargin >= 3 && t
    t = t && isequaln(x, varargin{:});
  end

end

%!error isequaln (symfun('x + 1', x))

%!test
%! syms x y
%! f(x) = 2*x;
%! g(x) = 2*x;
%! assert (isequaln (f, g))

%!test
%! syms x
%! f(x) = 2*x + 1;
%! g(x) = 2*x + 1;
%! h(x) = 2*x + 1;
%! assert (isequaln (f, g, h))

%!test
%! syms x
%! f(x) = 2*x + 1;
%! g(x) = 2*x + 1;
%! h(x) = 2*x;
%! assert (~ isequaln (f, g, h))

%!test
%! syms x y
%! f(x) = 2*x;
%! g(x, y) = 2*x;
%! assert (~ isequaln (f, g))

%!test
%! syms x y
%! f(x) = symfun(nan, x);
%! g(x) = symfun(nan, x);
%! assert (isequaln (f, g))

%!test
%! syms x y
%! f(x) = symfun(nan, x);
%! g(x, y) = symfun(nan, x);
%! assert (~ isequaln (f, g))
