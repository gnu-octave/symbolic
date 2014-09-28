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

