%% Copyright (C) 2014-2017 Colin B. Macdonald
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
%% @defmethod  @@sym ezplot (@var{f})
%% @defmethodx @@sym ezplot (@var{f1}, @var{f2})
%% @defmethodx @@sym ezplot (@var{f}, @var{dom})
%% @defmethodx @@sym ezplot (@var{f1}, @var{f2}, @var{dom})
%% @defmethodx @@sym ezplot (@dots{}, @var{N})
%% Simple plotting of symbolic expressions.
%%
%% Example parametric plot of a Lissajous Curve:
%% @example
%% @group
%% syms t
%% x = cos(3*t), y = sin(2*t)
%%   @result{} x = (sym) cos(3⋅t)
%%   @result{} y = (sym) sin(2⋅t)
%%
%% ezplot(x, y)                                 % doctest: +SKIP
%% @end group
%% @end example
%%
%% Example plotting the zero level curve of a function of two
%% variables:
%% @example
%% @group
%% syms x y
%% f = x^2 + y^2 - 1;
%% ezplot (f)                                   % doctest: +SKIP
%% @end group
%% @end example
%% Here the curve is defined implicitly by @code{f(x, y) == 0},
%% but we do not enter the @code{== 0} part.
%%
%% See help for the (non-symbolic) @code{ezplot}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% Using sym arguments for @var{dom} and @var{n} can lead to
%% ambiguity where OctSymPy cannot tell if you are specifying @var{n}
%% or @var{f2}.  For example:
%% @example
%% @group
%% syms t
%% f = sin(t);
%% N = sym(50);
%%
%% % parametric plot of f(t), N(t)
%% ezplot(f, N)                                 % doctest: +SKIP
%%
%% % plot f vs t using 50 pts
%% ezplot(f, double(N))                         % doctest: +SKIP
%% @end group
%% @end example
%%
%% The solution, as shown in the example, is to convert the sym to
%% a double.
%%
%% @seealso{ezplot, @@sym/ezplot3, @@sym/ezsurf, @@sym/function_handle}
%% @end defmethod


function varargout = ezplot(varargin)

  % first input is handle, shift
  if (ishandle(varargin{1}))
    fshift = 1;
  else
    fshift = 0;
  end

  firstsym = [];

  for i = (1+fshift):nargin
    if (isa(varargin{i}, 'sym'))
      if ( (i == 1 + fshift) || ...
           (i == 2 + fshift && isscalar(varargin{i})) ...
         )
        % This is one of the fcns to plot, so convert to handle fcn
        % The "i == 2" issscalar cond is to supports ezplot(f, sym([0 1]))

        % Each is function of one var, and its the same var for all
        % (or could be a single function of two variables)
        thissym = symvar(varargin{i});
        assert(length(thissym) <= 2, ...
          'ezplot: plotting curves: functions should have at most two inputs');
        if (isempty(thissym))
          % a number, create a constant function in a dummy variable
          % (0*t works around some Octave oddity on 3.8 and hg Dec 2014)
          thisf = inline(sprintf('%g + 0*t', double(varargin{i})), 't');
          %thisf = @(t) 0*t + double(varargin{i});  % no
        else
          % check variables match (sanity check)
          if (isempty(firstsym))
            firstsym = thissym;
          else
            assert (all (logical (thissym == firstsym)), ...
              'ezplot: all functions must be in terms of the same variables');
          end
          thisf = function_handle(varargin{i});
        end

        varargin{i} = thisf;

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


%%!shared hf
%%! % offscreen rendering currently (2016-06) causing crashes:
%%! % e.g., https://savannah.gnu.org/bugs/?44478
%%! hf = figure ('visible', 'off');

%!test
%! % simple
%! syms x
%! f = cos(x);
%! h = ezplot(f);
%! xx = get(h, 'xdata');
%! yy = get(h, 'ydata');
%! assert (abs(yy(end) - cos(xx(end))) <= 2*eps)
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! % matlab misses endpoint with nodisplay
%! assert (abs(xx(end) - 2*pi) <= 4*eps)
%! assert (abs(yy(end) - cos(2*pi)) <= 4*eps)
%! end

%!test
%! % parametric
%! syms t
%! x = cos(t);
%! y = sin(t);
%! h = ezplot(x, y);
%! xx = get(h, 'xdata');
%! assert (abs(xx(end) - cos(2*pi)) <= 4*eps)

%!error <all functions must be in terms of the same variables>
%! syms x t
%! ezplot(t, x)

%!error
%! syms x t
%! ezplot(t, t*x)

%!test
%! % implicit plot of f(x,y) == 0
%! syms x y
%! f = sqrt(x*x + y*y) - 1;
%! h = ezplot(f);
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   xx = get (h, 'xdata');
%!   yy = get (h, 'ydata');
%! else
%!   if (isempty (get (h, 'zdata')))
%!     xx = get (h, 'xdata');
%!     yy = get (h, 'ydata');
%!   else
%!     cm = get (h, 'ContourMatrix');
%!     xx = cm(1, 2:end);
%!     yy = cm(2, 2:end);
%!     assert (cm(1, 1) == 0)
%!     assert (cm(2, 1) == length (xx))
%!   end
%! end
%! assert (abs (max (xx) - 1) <= 0.02)
%! assert (abs (max (yy) - 1) <= 0.02)

%!error
%! % implicit plot supports single function
%! syms x y
%! f = sqrt(x*x + y*y) - 1;
%! g = sqrt(x*x + y*y) - 4;
%! h = ezplot(f, g);

%!test
%! % bounds etc as syms
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! % this number-of-points option not supported on matlab
%! syms x
%! f = cos(x);
%! h = ezplot(f, [0 2*sym(pi)], sym(42));
%! y = get(h, 'ydata');
%! assert (length(y) == 42)
%! assert (abs(y(end) - cos(4*pi)) <= 4*eps)
%! end

%!test
%! close all

%%!test
%%! close (hf);
