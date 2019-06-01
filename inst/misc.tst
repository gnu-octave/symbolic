%% Copyright (C) 2014, 2016-2017, 2019 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
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

%% some new tests, may want to put elsewhere...


%!shared x
%! syms x

%!assert (isequal (x(1), x));
%!assert (isequal (x(end), x));

%!error <subscript.*either.*integers> x(0)
%!error <subscript.*either.*integers> x(-1)

%!error <index out of range> x(end+1)

%!error <index out of range> x(42, 42)
%!error <index out of range> x(1, 42)
%!error <index out of range> x(42, 1)

%!assert (isequal (x(1, 1), x));
%!assert (isequal (x(:, :), x));
%!assert (isequal (x(:), x));

%!error <invalid ind> x('::')
%!error <invalid ind> x(1, '::')


%!shared a
%! syms x
%! a = [1 2 x];

%!error <index out of range> a(42, 42)
%!error <index out of range> a(0, 1)
%!error <index out of range> a(1, 0)

%!shared x
%! syms x

%!error x([1 2; 1 1])
%!error <index out of range> x([1 2])

%!test
%! % matrix index into matrix
%! m = [1 x; 3 6*x];
%! assert (isequal (m([4 1; 3 3]), [6*x 1; x x]))

%!test
%! % vector index into matrix, orientation, prompted by issue #114
%! m = [0 x; 2*x 3];
%! assert (isequal (m([2; 1; 3]), [2*x; 0; x]))
%! assert (isequal (m([2 1 3]), [2*x 0 x]))

%!test
%! % matrix index into vector (scalar), issue #113
%! assert (isequal (x([1 1; 1 1]), [x x; x x]))
%! assert (isequal (x([1 1]), [x x]))
%! assert (isequal (x([1; 1]), [x; x]))

%!test
%! % matrix index into vector (scalar), issue #113
%! a = [1 x 3];
%! assert (isequal (a([1 2; 2 3]), [1 x; x 3]))
%! % but vec into vec takes orientation from a
%! assert (isequal (a([2 3]), [x 3]))
%! assert (isequal (a([2; 2]), [x x]))

%!test
%! % matrix index into vector
%! a = [10 20 x];
%! assert (isequal (a([3 1; 3 2]), [x 10; x 20]))

%!test
%! % empty indexing
%! assert (isempty (x([])))
%! assert (isequal (size(x([])), [0 0]))
%! m = [0 x 1; 2*x 3 0];
%! assert (isequal (size(m([])), [0 0]))
%! assert (isequal (size(m([],[])), [0 0]))
%! assert (isequal (size(m(:,[])), [2 0]))
%! assert (isequal (size(m([],:)), [0 3]))

%!shared

%!test
%! r = pycall_sympy__ ('return Version("0.7.6") > Version("0.7.6"),');
%! assert (isequal (r, false))

%!test
%! r = pycall_sympy__ ('return Version("0.7.6") >= Version("0.7.6"),');
%! assert (isequal (r, true))

%!xtest
%! % see: https://github.com/cbm755/octsympy/pull/320
%! r = pycall_sympy__ ('return Version("0.7.6") > Version("0.7.6.dev"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("0.7.6") >= Version("0.7.6.dev"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("0.7.6.1") > Version("0.7.6"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("0.7.6.1") >= Version("0.7.6"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("0.7.6.1.dev") >= Version("0.7.6"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("0.7.6.dev") >= Version("0.7.5"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("1.0.1") > Version("1.0"),');
%! assert (isequal (r, true))

%!test
%! r = pycall_sympy__ ('return Version("1.0") > Version("0.7.6"),');
%! assert (isequal (r, true))
