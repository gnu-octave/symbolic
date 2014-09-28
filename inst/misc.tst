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


% no shared as makes xfail tests noiser
%!shared

%!xtest
%! % FIXME: matrix index into matrix
%! syms x
%! m = [1 x; 3 6*x];
%! % less serious, raises error
%! assert (isequal (m([4 1; 2 2]), [6*x 1; x x]))

%!xtest
%! % FIXME: vector index into vector, orientation, issue #114
%! syms x
%! a = [10 20 x];
%! assert (isequal (a([3 2]), [x 20]))
%! assert (isequal (a([2; 2; 3; 1]), [20; 20; x; 10]))
%! a = [10; x];
%! assert (isequal (a([2; 1; 2]), [x; 10; x]))
%! assert (isequal (a([2 1 2]), [x 10 x]))

%!xtest
%! % FIXME: matrix index into vector, issue #113
%! syms x
%! assert (isequal (x([1 1; 1 1]), [x x; x x]))

%!xtest
%! % FIXME: matrix index into vector
%! syms x
%! a = [10 20 x];
%! % less serious, raises error
%! assert (isequal (a([3 1; 3 2]), [x 10; x 20]))
