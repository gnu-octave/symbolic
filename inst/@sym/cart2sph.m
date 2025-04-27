%% Copyright (C) 2025 Swayam Shah
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
%% @deftypemethod  @@sym {[@var{theta}, @var{phi}, @var{r}] =} cart2sph (@var{x}, @var{y}, @var{z})
%% @deftypemethodx @@sym {[@var{theta}, @var{phi}, @var{r}] =} cart2sph (@var{C})
%% Transform symbolic Cartesian coordinates to spherical coordinates.
%%
%% If called with three inputs @var{x}, @var{y}, and @var{z}, they must be of
%% the same shape or scalar.  The shape of the outputs @var{theta}, @var{phi},
%% and @var{r} matches that of the inputs (except when the input is a scalar).
%%
%% If called with a single input @var{C}, it must be a column vector with 3
%% entries or a matrix with 3 columns.  The column vector or each row of the
%% matrix represents a point in Cartesian coordinates (@var{x}, @var{y},
%% @var{z}).  If input @var{C} is a column vector, outputs @var{theta},
%% @var{phi}, and @var{r} are scalars.  Otherwise, the shape of the outputs is
%% a column vector with each row corresponding to that of the input matrix
%% @var{C}.
%%
%% Given a point (@var{x}, @var{y}, @var{z}) in Cartesian coordinates, its
%% corresponding spherical coordinates are:
%% @var{theta} = @code{atan2(@var{y}, @var{x})}
%% @var{phi} = @code{atan2(@var{z}, sqrt(@var{x}^2 + @var{y}^2))}
%% @var{r} = @code{sqrt(@var{x}^2 + @var{y}^2 + @var{z}^2)}
%%
%% @seealso{cart2sph, sph2cart, cart2pol, pol2cart}
%% @end deftypemethod

function [theta, phi, r] = cart2sph (x, y, z)
  if nargin == 1
    C = sym (x);
    sz = size (C);
    nrows = sz(1);
    ncols = sz(2);
    if isequal (sz, [3 1])
      args = num2cell (C);
      [theta, phi, r] = cart2sph (args{:});
    elseif ncols == 3
      args = arrayfun (@(k) subsref (C, substruct ('()', {':', k})), 1:ncols, 'UniformOutput', false);
      [theta, phi, r] = cart2sph (args{:});
    else
      warning ('cart2sph: C must be a column vector with 3 entries or a matrix with 3 columns');
      print_usage ();
    end
    return
  elseif nargin != 3
    print_usage ();
  end

  x = sym (x);
  y = sym (y);
  z = sym (z);
  non_scalar_sizes = {};
  if numel(x) > 1
    non_scalar_sizes{end+1} = size(x);
  end
  if numel(y) > 1
    non_scalar_sizes{end+1} = size(y);
  end
  if numel(z) > 1
    non_scalar_sizes{end+1} = size(z);
  end

  if ~isempty(non_scalar_sizes)
    sz = non_scalar_sizes{1};
    for i = 2:length(non_scalar_sizes)
      if ~isequal(sz, non_scalar_sizes{i})
        error('cart2sph: all non-scalar inputs must have the same size');
      end
    end
  else
    sz = [1,1];
  end

  theta = atan2 (y, x);
  phi = atan2 (z, sqrt (x.^2 + y.^2));
  r = sqrt (x.^2 + y.^2 + z.^2);
end

%!test
%! % Single scalar inputs
%! syms x y z real
%! [theta, phi, r] = cart2sph (x, y, z);
%! assert (isequal (theta, atan2(y, x)));
%! assert (isequal (phi, atan2(z, sqrt(x^2 + y^2))));
%! assert (isequal (r, sqrt(x^2 + y^2 + z^2)));

%!test
%! % Column vector with 3 entries
%! syms x y z real
%! C = [x; y; z];
%! [theta, phi, r] = cart2sph (C);
%! assert (isequal (theta, atan2(y, x)));
%! assert (isequal (phi, atan2(z, sqrt(x^2 + y^2))));
%! assert (isequal (r, sqrt(x^2 + y^2 + z^2)));

%!test
%! % Matrix with 3 columns
%! syms x1 y1 z1 x2 y2 z2 real
%! C = [x1 y1 z1; x2 y2 z2];
%! [theta, phi, r] = cart2sph (C);
%! assert (isequal (theta, [atan2(y1, x1); atan2(y2, x2)]));
%! assert (isequal (phi, [atan2(z1, sqrt(x1^2 + y1^2)); atan2(z2, sqrt(x2^2 + y2^2))]));
%! assert (isequal (r, [sqrt(x1^2 + y1^2 + z1^2); sqrt(x2^2 + y2^2 + z2^2)]));

%!test
%! % Mixing scalar and array inputs
%! x = sym ([1, 0]);
%! y = sym ([0, 1]);
%! z = sym (0);
%! [theta, phi, r] = cart2sph (x, y, z);
%! assert (isequal (theta, [0, pi/2]));
%! assert (isequal (phi, [0, 0]));
%! assert (isequal (r, [1, 1]));

%!test
%! % Numerical inputs
%! [theta, phi, r] = cart2sph (1, 0, 0);
%! assert (isequal (theta, sym(0)));
%! assert (isequal (phi, sym(0)));
%! assert (isequal (r, sym(1)));