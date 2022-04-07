%% Copyright (C) 2020 Tasos Papastylianou
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
%% @defmethod  @@sym cumprod (@var{x})
%% @defmethodx @@sym cumprod (@var{x}, @var{dim})
%% Perform a cumulative product over the rows or columns of a symbolic array.
%%
%% If @var{dim} is omitted, it defaults to the first non-singleton dimension.
%% For example:
%%
%% Examples:
%% @example
%% @group
%% t = sym ('t');
%% Pi = sym ('pi');
%% T = [t; t + Pi / 2; t + Pi; t + 3 * Pi / 2; t + 2 * Pi];
%% C = cos (T);
%% cumprod (C)
%%   @result{} (sym 5×1 matrix)
%%       ⎡    cos(t)     ⎤
%%       ⎢               ⎥
%%       ⎢-sin(t)⋅cos(t) ⎥
%%       ⎢               ⎥
%%       ⎢          2    ⎥
%%       ⎢sin(t)⋅cos (t) ⎥
%%       ⎢               ⎥
%%       ⎢   2       2   ⎥
%%       ⎢sin (t)⋅cos (t)⎥
%%       ⎢               ⎥
%%       ⎢   2       3   ⎥
%%       ⎣sin (t)⋅cos (t)⎦
%% @end group
%% @end example
%%
%% Specify dimension along which to compute the product:
%% @example
%% @group
%% X = repmat (sym ('x'), 2, 3 );
%%
%% cumprod (X, 1)
%%   @result{} (sym 2×3 matrix)
%%       ⎡x   x   x ⎤
%%       ⎢          ⎥
%%       ⎢ 2   2   2⎥
%%       ⎣x   x   x ⎦
%%
%% cumprod (X, 2)
%%   @result{} (sym 2×3 matrix)
%%       ⎡    2   3⎤
%%       ⎢x  x   x ⎥
%%       ⎢         ⎥
%%       ⎢    2   3⎥
%%       ⎣x  x   x ⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/prod, @@sym/cumsum}
%% @end defmethod


function y = cumprod (x, dim)

  %% Check correctness of input arguments
  if (nargin > 2)
    print_usage ();
  endif

  if (nargin == 2)

    assert (
      !isempty (dim),
      sprintf ("@sym/cumprod: dimension argument is an empty object")
    );

    assert (
      isnumeric (dim),
      sprintf ("@sym/cumprod: invalid dimension argument type: %s", class (dim))
    );

    dim = floor (dim(1));   % behaviour compatible with builtin cumprod

    assert (
      dim > 0,
      sprintf( "@sym/cumprod: invalid dimension argument: %d", dim)
    );

  else  % (nargin == 1)

    %% Find first non-singleton dimension.
    if (all (size (x) == [1, 1]))
      y = x;   % For efficiency, but also if we didn't do this explicitly, the
      return   % 'find' operation below would return the invalid result '[]'
    else
      %% Note: This is a general formulation supporting multidimensional inputs,
      %% even though at the time of writing symbolic arrays are restricted to
      %% having no more than two dimensions (e.g. see @sym/cat)
      dim = find (size (x) > 1, 1);
    endif

  endif


  ydims   = size (x);
  dimsize = ydims(dim);
  y       = sym (zeros (ydims));
  xidx    = substruct ('()', repmat ({':'}, 1, ndims (x)));
  yidx    = substruct ('()', repmat ({':'}, 1, ndims (y)));

  for i = 1 : dimsize
    xidx.subs{dim} = 1 : i;
    yidx.subs{dim} = i;
    y = subsasgn (y,  yidx,  prod (subsref (x, xidx), dim));
  endfor

endfunction


%!shared x, y
%! x = sym ('x');
%! y = sym ('y');
%!assert (isequal (cumprod ([-x; -2*x; -3*x]), [-x; 2*x^2; -6*x^3]))
%!assert (isequal (expand (cumprod ([x + i, x - i])), [x + i, x^2 + 1]))
%!assert (isequal (cumprod ([1, x; y, 2], 1), [1, x; y, 2*x] ))
%!assert (isequal (cumprod ([1, x; y, 2], 2), [1, x; y, 2*y] ))
%!test cumprod ([x, x], [2,  1]);   # ensure behaves like builtin cumprod
%!test cumprod ([x, x], [1, -2]);   # ensure behaves like builtin cumprod
%!error <Invalid call> cumprod (x, 1, 2)
%!error <empty> cumprod (x, [])
%!error <invalid dimension argument type> cumprod (x, {1})
%!error <invalid dimension argument type> cumprod (x, struct('a', 1))
%!error <invalid dimension argument type> cumprod (x, x)
%!error <invalid dimension argument> cumprod (x, 0)
%!error <invalid dimension argument> cumprod (x, -1)
