%% Copyright (C) 2022 Alex Vong
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
%% If not, see <https://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypemethod  @@sym {[@var{theta}, @var{r}] =} cart2pol (@var{x}, @var{y})
%% @deftypemethodx @@sym {[@var{theta}, @var{r}, @var{z}] =} cart2pol (@var{x}, @var{y}, @var{z})
%% @deftypemethodx @@sym {[@var{theta}, @var{r}] =} cart2pol (@var{C})
%% @deftypemethodx @@sym {[@var{theta}, @var{r}, @var{z}] =} cart2pol (@var{C})
%% Transform symbolic Cartesian coordinates into symbolic polar or cylindrical
%% coordinates.
%%
%% If called with inputs @var{x}, @var{y} (and @var{z}), they must be of the
%% same shape or a scalar.  The shape of the outputs @var{theta}, @var{r} (and
%% @var{z}) matches those of the inputs (except when the input is a scalar).
%%
%% If called with a single input @var{C}, it must be a column vector with 2 or
%% 3 entries, or a matrix with 2 or 3 columns.  The column vector or each row
%% of the matrix represents a point in Cartesian coordinates (@var{x}, @var{y})
%% or (@var{x}, @var{y}, @var{z}).  If input @var{C} is a column vector,
%% outputs @var{theta}, @var{r} (and @var{z}) is a scalar.  Otherwise, the
%% shape of the outputs @var{theta}, @var{r} (and @var{z}) is a column vector
%% with each row corresponding to that of the input matrix @var{C}.
%%
%% Given a point (@var{x}, @var{y}) in Cartesian coordinates, its corresponding
%% polar coordinates can be obtained by:
%% @example
%% @group
%% syms x y real
%% [theta, r] = cart2pol (x, y)
%%   @result{} theta = (sym) atan2(y, x)
%%     r = (sym)
%%          _________
%%         ╱  2    2
%%       ╲╱  x  + y
%% @end group
%% @end example
%%
%% Similarly, given a point (@var{x}, @var{y}, @var{z}) in Cartesian
%% coordinates, its corresponding cylindrical coordinates can be obtained by:
%% @example
%% @group
%% syms x y z real
%% [theta, r, z] = cart2pol (x, y, z)
%%   @result{} theta = (sym) atan2(y, x)
%%     r = (sym)
%%          _________
%%         ╱  2    2
%%       ╲╱  x  + y
%%     z = (sym) z
%% @end group
%% @end example
%%
%% @seealso{cart2pol}
%% @end deftypemethod


function [theta, r, z_out] = cart2pol (x_in, y_in, z_in)
  %% obtain the kth column of matrix A
  column_ref = @(A, k) subsref (A, substruct ('()', {':', k}));

  if nargin == 1
    C = sym (x_in);
    sz = size (C);
    nrows = sz(1);
    ncols = sz(2);
    if isequal (sz, [2 1])
      args = num2cell (C);
      [theta, r] = cart2pol (args{:});
    elseif isequal (sz, [3 1])
      args = num2cell (C);
      [theta, r, z_out] = cart2pol (args{:});
    elseif ncols == 2
      args = arrayfun (@(k) column_ref (C, k), 1:ncols, 'UniformOutput', false);
      [theta, r] = cart2pol (args{:});
    elseif ncols == 3
      args = arrayfun (@(k) column_ref (C, k), 1:ncols, 'UniformOutput', false);
      [theta, r, z_out] = cart2pol (args{:});
    else
      warning ('cart2pol: C must be a column vector with 2 or 3 entries, or a matrix with 2 or 3 columns');
      print_usage ();
    end
    return
  end

  x = sym (x_in);
  y = sym (y_in);
  if isscalar (size (x))
    sz = size (y);
  elseif isscalar (size (y)) || isequal (size (x), size (y))
    sz = size (x);
  else
    error ('cart2pol: all inputs must have compatible sizes');
  end
  r = hypot (sym (x), sym (y));
  theta = atan2 (sym (y), sym (x));

  if nargin == 3
    z = sym (z_in);
    if isscalar (z)
      z_out = z * ones (sz);
    elseif isequal(size (z), sz)
      z_out = z;
    else
      error ('cart2pol: all inputs must have compatible sizes');
    end
  end
end


%!test
%! % multiple non-scalar inputs
%! x = sym ('x', [2 2]);
%! assume (x, 'real');
%! y = sym ('y', [2 2]);
%! assume (y, 'real');
%! [theta, r] = cart2pol (x, y);
%! assert (isequal (r, sqrt (x.^2 + y.^2)));
%! assert (isequal (tan (theta), y ./ x));
%! % mixing scalar inputs with non-scalar inputs
%! syms z real
%! [theta_2, r_2, z_2] = cart2pol (x, y, z);
%! assert (isequal (r_2, sqrt (x.^2 + y.^2)));
%! assert (isequal (tan (theta_2), y ./ x));
%! assert (isequal (z_2, z * ones (2, 2)));

%!test
%! % column vector with 2 entries
%! syms x y real
%! [theta, r] = cart2pol ([x; y]);
%! assert (isequal (r, sqrt (x.^2 + y.^2)));
%! assert (isequal (tan (theta), y ./ x));
%! % column vector with 3 entries
%! syms z real
%! [theta_2, r_2, z_2] = cart2pol ([x; y; z]);
%! assert (isequal (r_2, sqrt (x.^2 + y.^2)));
%! assert (isequal (tan (theta_2), y ./ x));
%! assert (isequal (z_2, z));

%!test
%! % matrix with 2 columns
%! syms x y u v real
%! C = [x y; u v];
%! [theta, r] = cart2pol (C);
%! assert (isequal (r, [sqrt(x.^2+y.^2); sqrt(u.^2+v.^2)]));
%! assert (isequal (tan (theta), [y/x; v/u]));
%! % matrix with 3 columns
%! syms z w real
%! C_2 = [x y z; u v w];
%! [theta_2, r_2, z_2] = cart2pol (C_2);
%! assert (isequal (r, [sqrt(x.^2+y.^2); sqrt(u.^2+v.^2)]));
%! assert (isequal (tan (theta), [y/x; v/u]));
%! assert (isequal (z_2, [z; w]));
