%% SPDX-License-Identifier: GPL-3.0-or-later
%% Copyright (C) 2023-2024 Colin B. Macdonald
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
%% @defmethod  @@sym fplot (@var{f})
%% @defmethodx @@sym fplot (@var{f}, @var{limits})
%% @defmethodx @@sym fplot (@dots{}, @dots{}, @var{N})
%% @defmethodx @@sym fplot (@dots{}, @dots{}, @var{tol})
%% @defmethodx @@sym fplot (@dots{}, @dots{}, @var{fmt})
%% @defmethodx @@sym {[@var{x}, @var{y}] =} fplot (@dots{})
%% Plot a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% y = cos(3*x)
%%   @result{} y = (sym) cos(3⋅x)
%%
%% @c doctest: +SKIP
%% fplot (y)
%%
%% @c doctest: +SKIP
%% fplot (y, [0 pi])
%% @end group
%% @end example
%%
%% You can also grab the data that would be plotted and plot it
%% yourself:
%% @example
%% @group
%% syms x
%%
%% [xx, yy] = fplot (sin (x), [0 1])
%%   @result{} xx =
%%       0
%%       ...
%%       1.0000
%%   @result{} yy =
%%       0
%%       ...
%%       0.8415
%%
%% plot (xx, yy)
%% @end group
%% @end example
%%
%% See help for the (non-symbolic) @code{fplot}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% @seealso{fplot, @@sym/ezplot, @@sym/function_handle}
%% @end defmethod


function [xx, yy] = fplot (varargin)

  % first input is handle, shift
  if (ishandle (varargin{1}))
    fshift = 1;
  else
    fshift = 0;
  end

  for i = (1+fshift):nargin
    if (isa (varargin{i}, 'sym'))
      if (i == 1 + fshift)
        thissym = symvar (varargin{i});
        assert (length (thissym) <= 1, ...
          'fplot: functions should have at most one input');
        if (isempty (thissym))
          thisf = function_handle (varargin{i}, 'vars', sym ('x'));
        else
          thisf = function_handle (varargin{i});
        end

        varargin{i} = thisf;

      else
        % plot ranges, etc, convert syms to doubles
        varargin{i} = double (varargin{i});
      end
    end
  end

  if (nargout)
    [xx, yy] = fplot (varargin{:});
  else
    fplot(varargin{:});
  end

end


%!test
%! % simple
%! syms x
%! f = cos (x);
%! fplot (f);

%!test
%! % constant function
%! fplot (sym (10));

%!test
%! syms x
%! f = cos (x);
%! [xx, yy] = fplot (f);
%! assert (xx(1), -5)
%! assert (xx(end), 5)
%! assert (min (yy), -1, 0.1)
%! assert (max (yy), 1, 0.1)

%!test
%! syms x
%! f = cos (x);
%! dom = [1 3];
%! [xx, yy] = fplot (f, dom);
%! assert (xx(1), dom(1))
%! assert (xx(end), dom(2))

%!test
%! syms x
%! f = cos (x);
%! dom = [1 3];
%! fplot (f, dom);
%! assert (get (gca, 'xlim'), dom)

%!test
%! syms x
%! f = exp (x);
%! dom = [1 2 3 4];
%! fplot (f, dom);
%! assert (get (gca, 'xlim'), dom(1:2))
%! assert (get (gca, 'ylim'), dom(3:4))

%!test
%! % bounds as syms
%! syms x
%! f = cos (x);
%! dom = [1 2 3 4];
%! fplot (f, sym (dom));
%! assert (get (gca, 'xlim'), dom(1:2))
%! assert (get (gca, 'ylim'), dom(3:4))

%!test
%! % bounds as syms, regular handle for function
%! % fails on 6.1.0, maybe earlier too?
%! if (compare_versions (OCTAVE_VERSION (), '6.1.0', '<='))
%!   dom = [1 2];
%!   fplot (@cos, sym (dom));
%!   assert (get (gca, 'xlim'), dom(1:2))
%! end

%!error <at most one>
%! syms x y
%! fplot (x*y)

%!test
%! % N parameter does something
%! syms x
%! [xx, yy] = fplot (sin (x), [0 2], 5);
%! N = length (xx);
%! assert (N >= 5)
%! [xx, yy] = fplot (sin (x), [0 2], 1000);
%! N = length (xx);
%! assert (N == 1000)

%!test
%! % tolerance parameter does something
%! syms x
%! [xx, yy] = fplot (sin (exp (x/2)), [0 3], 0.1);
%! N1 = length (xx);
%! [xx, yy] = fplot (sin (exp (x/2)), [0 3], 0.01);
%! N2 = length (xx);
%! assert (N2 > N1)

%!test
%! % fmt parameter does something
%! syms x
%! fplot (sin (x), [0 6], 'rx--', 'linewidth', 5);
%! l = get (gca (), 'children');
%! assert (get (l, 'color'), [1 0 0])
%! assert (get (l, 'linewidth'), 5)

%! f = exp (x);
%! dom = [1 2 3 4];
%! fplot (f, dom);
%! assert (get (gca, 'xlim'), dom(1:2))
%! assert (get (gca, 'ylim'), dom(3:4))

%!test
%! close all
