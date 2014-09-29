%% some new tests, may want to put elsewhere...


%!shared x
%! syms x

%!assert (isequal (x(1), x));
%!assert (isequal (x(end), x));

%!error <subscript indices must be either positive> x(0)
%!error <subscript indices must be either positive> x(-1)

%!error <index out of range> x(end+1)

%!error <index out of range> x(42, 42)
%!error <index out of range> x(1, 42)
%!error <index out of range> x(42, 1)

%!assert (isequal (x(1, 1), x));
%!assert (isequal (x(:, :), x));
%!assert (isequal (x(:), x));

%!error <invalid indexing> x('::')
%!error <unknown 2d> x(1, '::')


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
