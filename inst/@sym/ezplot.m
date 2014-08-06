%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{h} =} ezplot (@var{f})
%% @deftypefnx {Function File} {@var{h} =} ezplot (@var{f1}, @var{f2})
%% @deftypefnx {Function File} {@var{h} =} ezplot (...)
%% Simple plotting of symbolic expressions.
%%
%% See help for the (non-symbolic) @code{ezplot}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% Using sym arguments for @var{dom} and @var{n} can lead to
%% ambiguity.  For example
%% @example
%% syms t
%% f = sin(t)
%% N = sym(50)
%% ezplot(f, N)    % a parametric plot of f(t), N(t)
%% ezplot(f, double(N))   % plot f vs t using 50 pts
%% @end example
%% the solution, as above, is to convert the sym to a double.
%%
%% FIXME: should call symvar on all of them at once?
%%
%% @seealso{ezplot3, ezsurf, ezmesh, matlabFunction}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, plotting

function varargout = ezplot(varargin)

  % first input is handle, shift
  if (ishandle(varargin{1}))
    fshift = 1;
  else
    fshift = 0;
  end

  for i = (1+fshift):nargin
    if (isa(varargin{i}, 'sym'))
      if ( (i == 1 + fshift) || ...
           (i == 2 + fshift && isscalar(varargin{i})) ...
         )
        % one of the fcns to plot, convert to handle fcn
        % i == 2 extra cond.: ezplot(f, sym([0 1]))
        varargin{i} = matlabFunction(varargin{i});
      else
        % plot ranges, etc, convert syms to doubles
        varargin{i} = double(varargin{i});
      end
    end
  end

  h = ezplot(varargin{:});

  if (nargout)
    varargout{1} = h;
  end

end


%!test
%! % simple
%! syms x
%! f = cos(x);
%! h = ezplot(f);
%! y = get(h, 'ydata');
%! assert (abs(y(end) - cos(2*pi)) <= 4*eps)

%!test
%! % parametric
%! syms t
%! x = cos(t);
%! y = sin(t);
%! h = ezplot(x, y);
%! xx = get(h, 'xdata');
%! assert (abs(xx(end) - cos(2*pi)) <= 4*eps)

%!test
%! % contour
%! syms x y
%! f = sqrt(x*x + y*y) - 1;
%! h = ezplot(f);
%! y = get(h, 'ydata');
%! assert (max(y) - 1 <= 4*eps)

%!test
%! % bounds etc as syms
%! syms x
%! f = cos(x);
%! h = ezplot(f, [0 2*sym(pi)], sym(42));
%! y = get(h, 'ydata');
%! assert (length(y) == 42)
%! assert (abs(y(end) - cos(4*pi)) <= 4*eps)

