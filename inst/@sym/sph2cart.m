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
%% @deftypemethod  @@sym {[@var{x}, @var{y}, @var{z}] =} sph2cart (@var{theta}, @var{phi}, @var{r})
%% @deftypemethodx @@sym {[@var{x}, @var{y}, @var{z}] =} sph2cart (@var{S})
%% Transform symbolic spherical coordinates to Cartesian coordinates.
%%
%% If called with three inputs @var{theta}, @var{phi}, and @var{r}, they must
%% be of the same shape or scalar.  The shape of the outputs @var{x}, @var{y},
%% and @var{z} matches that of the non-scalar inputs, with scalars broadcasted
%% appropriately.
%%
%% If called with a single input @var{S}, it must be a column vector with 3
%% entries or a matrix with 3 columns.  The column vector or each row of the
%% matrix represents a point in spherical coordinates (@var{theta}, @var{phi},
%% @var{r}).  If input @var{S} is a column vector, outputs @var{x}, @var{y},
%% and @var{z} are scalars.  Otherwise, the shape of the outputs is a column
%% vector with each row corresponding to that of the input matrix @var{S}.
%%
%% Given a point (@var{theta}, @var{phi}, @var{r}) in spherical coordinates,
%% its corresponding Cartesian coordinates are:
%% @var{x} = @code{r * cos(@var{phi}) * cos(@var{theta})}
%% @var{y} = @code{r * cos(@var{phi}) * sin(@var{theta})}
%% @var{z} = @code{r * sin(@var{phi})}
%%
%% @seealso{sph2cart, cart2sph, cart2pol, pol2cart}
%% @end deftypefn

function [x, y, z] = sph2cart (theta, phi, r)
  if nargin == 1
    C = sym (theta);
    sz = size (C);
    nrows = sz(1);
    ncols = sz(2);
    if isequal (sz, [3 1])
      args = num2cell (C);
      [x, y, z] = sph2cart (args{:});
    elseif ncols == 3
      args = arrayfun (@(k) subsref (C, substruct ('()', {':', k})), 1:ncols, 'UniformOutput', false);
      [x, y, z] = sph2cart (args{:});
    else
      warning ('sph2cart: S must be a column vector with 3 entries or a matrix with 3 columns');
      print_usage ();
    end
    return
  elseif nargin != 3
    print_usage ();
  end

  theta = sym (theta);
  phi = sym (phi);
  r = sym (r);
  non_scalar_sizes = {};
  if numel(theta) > 1
    non_scalar_sizes{end+1} = size(theta);
  end
  if numel(phi) > 1
    non_scalar_sizes{end+1} = size(phi);
  end
  if numel(r) > 1
    non_scalar_sizes{end+1} = size(r);
  end

  if ~isempty(non_scalar_sizes)
    sz = non_scalar_sizes{1};
    for i = 2:length(non_scalar_sizes)
      if ~isequal(sz, non_scalar_sizes{i})
        error('sph2cart: all non-scalar inputs must have the same size');
      end
    end
  else
    sz = [1,1];
  end

  if isscalar(theta)
    theta = theta * sym(ones(sz));
  end
  if isscalar(phi)
    phi = phi * sym(ones(sz));
  end
  if isscalar(r)
    r = r * sym(ones(sz));
  end

  x = r .* cos(phi) .* cos(theta);
  y = r .* cos(phi) .* sin(theta);
  z = r .* sin(phi);
end

%!test
%! % Single scalar inputs
%! syms theta phi r real
%! [x, y, z] = sph2cart (theta, phi, r);
%! assert (isequal (x, r * cos(phi) * cos(theta)));
%! assert (isequal (y, r * cos(phi) * sin(theta)));
%! assert (isequal (z, r * sin(phi)));

%!test
%! % Column vector with 3 entries
%! syms theta phi r real
%! S = [theta; phi; r];
%! [x, y, z] = sph2cart (S);
%! assert (isequal (x, r * cos(phi) * cos(theta)));
%! assert (isequal (y, r * cos(phi) * sin(theta)));
%! assert (isequal (z, r * sin(phi)));

%!test
%! % Matrix with 3 columns
%! syms t1 p1 r1 t2 p2 r2 real
%! S = [t1 p1 r1; t2 p2 r2];
%! [x, y, z] = sph2cart (S);
%! assert (isequal (x, [r1 * cos(p1) * cos(t1); r2 * cos(p2) * cos(t2)]));
%! assert (isequal (y, [r1 * cos(p1) * sin(t1); r2 * cos(p2) * sin(t2)]));
%! assert (isequal (z, [r1 * sin(p1); r2 * sin(p2)]));

%!test
%! % Mixing scalar and array inputs
%! t = sym ([0, pi/2]);
%! p = sym (0);
%! r = sym (1);
%! [x, y, z] = sph2cart (t, p, r);
%! assert (isequal (x, [1, 0]));
%! assert (isequal (y, [0, 1]));
%! assert (isequal (z, [0, 0]));

%!test
%! % Numerical inputs
%! [x, y, z] = sph2cart (0, 0, 1);
%! assert (isequal (x, sym(1)));
%! assert (isequal (y, sym(0)));
%! assert (isequal (z, sym(0)));