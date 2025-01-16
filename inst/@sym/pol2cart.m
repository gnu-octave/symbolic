%% Copyright (C) 2023 Swayam Shah
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
%% @deftypemethod  @@sym {[@var{x}, @var{y}] =} pol2cart (@var{theta}, @var{r})
%% @deftypemethodx @@sym {[@var{x}, @var{y}, @var{z}] =} pol2cart (@var{theta}, @var{r}, @var{z})
%% @deftypemethodx @@sym {[@var{x}, @var{y}] =} pol2cart (@var{P})
%% @deftypemethodx @@sym {[@var{x}, @var{y}, @var{z}] =} pol2cart (@var{P})
%% Transform symbolic polar or cylindrical coordinates into Cartesian.
%%
%% If called with inputs @var{theta}, @var{r} (and @var{z}), they must be of the
%% same shape or a scalar. The shape of the outputs @var{x}, @var{y} (and @var{z})
%% matches those of the inputs (except when the input is a scalar).
%%
%% If called with a single input @var{P}, it must be a column vector with 2 or
%% 3 entries, or a matrix with 2 or 3 columns. The column vector or each row
%% of the matrix represents a point in polar or cylindrical coordinates
%% (@var{theta}, @var{r}) or (@var{theta}, @var{r}, @var{z}). If input @var{P}
%% is a column vector, outputs @var{x}, @var{y} (and @var{z}) are scalars.
%% Otherwise, the shape of the outputs @var{x}, @var{y} (and @var{z}) is a
%% column vector with each row corresponding to that of the input matrix @var{P}.
%%
%% Given a point (@var{theta}, @var{r}) in polar coordinates, its corresponding
%% Cartesian coordinates can be obtained by:
%% @example
%% @group
%% syms theta r real
%% [x, y] = pol2cart (theta, r)
%%   @result{} x = (sym) r⋅cos(θ)
%%     y = (sym) r⋅sin(θ)
%% @end group
%% @end example
%%
%% Similarly, given a point (@var{theta}, @var{r}, @var{z}) in cylindrical
%% coordinates, its corresponding Cartesian coordinates can be obtained by:
%% @example
%% @group
%% syms theta r z real
%% [x, y, z] = pol2cart (theta, r, z)
%%   @result{} x = (sym) r⋅cos(θ)
%%     y = (sym) r⋅sin(θ)
%%     z = (sym) z
%% @end group
%% @end example
%%
%% @seealso{pol2cart, cart2pol}
%% @end deftypemethod

function [x, y, z_out] = pol2cart (theta_in, r_in, z_in)
  %% obtain the kth column of matrix A
  column_ref = @(A, k) subsref (A, substruct ('()', {':', k}));

  if nargin == 1
    P = sym (theta_in);
    sz = size (P);
    nrows = sz(1);
    ncols = sz(2);
    if isequal (sz, [2 1])
      args = num2cell (P);
      [x, y] = pol2cart (args{:});
    elseif isequal (sz, [3 1])
      args = num2cell (P);
      [x, y, z_out] = pol2cart (args{:});
    elseif ncols == 2
      args = arrayfun (@(k) column_ref (P, k), 1:ncols, 'UniformOutput', false);
      [x, y] = pol2cart (args{:});
    elseif ncols == 3
      args = arrayfun (@(k) column_ref (P, k), 1:ncols, 'UniformOutput', false);
      [x, y, z_out] = pol2cart (args{:});
    else
      warning ('pol2cart: P must be a column vector with 2 or 3 entries, or a matrix with 2 or 3 columns');
      print_usage ();
    end
    return
  end

  theta = sym (theta_in);
  r = sym (r_in);
  if isscalar (size (theta))
    sz = size (r);
  elseif isscalar (size (r)) || isequal (size (theta), size (r))
    sz = size (theta);
  else
    error ('pol2cart: all inputs must have compatible sizes');
  end
  x = r .* cos (theta);
  y = r .* sin (theta);

  if nargin == 3
    z = sym (z_in);
    if isscalar (z)
      z_out = z * ones (sz);
    elseif isequal(size (z), sz)
      z_out = z;
    else
      error ('pol2cart: all inputs must have compatible sizes');
    end
  end
end


%!test
%! % multiple non-scalar inputs
% ! theta = sym ('theta', [2 2]);
% ! assume (theta, 'real');
% ! r = sym ('r', [2 2]);
% ! assume (r, 'real');
% ! [x, y] = pol2cart (theta, r);
% ! assert (isequal (x, r .* cos (theta)));
% ! assert (isequal (y, r .* sin (theta)));
% ! % mixing scalar inputs with non-scalar inputs
% ! syms z real
% ! [x_2, y_2, z_2] = pol2cart (theta, r, z);
% ! assert (isequal (x_2, r .* cos (theta)));
% ! assert (isequal (y_2, r .* sin (theta)));
% ! assert (isequal (z_2, z * ones (2, 2)));

%!test
%! % column vector with 2 entries
%! syms theta r real
%! [x, y] = pol2cart ([theta; r]);
%! assert (isequal (x, r * cos (theta)));
%! assert (isequal (y, r * sin (theta)));
%! % column vector with 3 entries
%! syms z real
%! [x_2, y_2, z_2] = pol2cart ([theta; r; z]);
%! assert (isequal (x_2, r * cos (theta)));
%! assert (isequal (y_2, r * sin (theta)));
%! assert (isequal (z_2, z));

%!test
%! % matrix with 2 columns
%! syms theta r u v real
%! P = [theta r; u v];
%! [x, y] = pol2cart (P);
%! assert (isequal (x, [r * cos(theta); v * cos(u)]));
%! assert (isequal (y, [r * sin(theta); v * sin(u)]));
%! % matrix with 3 columns
%! syms z w real
%! P_2 = [theta r z; u v w];
%! [x_2, y_2, z_2] = pol2cart (P_2);
%! assert (isequal (x_2, [r * cos(theta); v * cos(u)]));
%! assert (isequal (y_2, [r * sin(theta); v * sin(u)]));
%! assert (isequal (z_2, [z; w]));