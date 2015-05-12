%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{h} =} ezplot (@var{f})
%% @deftypefnx {Function File} {@var{h} =} ezplot (@var{f1}, @var{f2})
%% @deftypefnx {Function File} {@var{h} =} ezplot (@dots{})
%% Simple plotting of symbolic expressions.
%%
%% See help for the (non-symbolic) @code{ezplot}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% Using sym arguments for @var{dom} and @var{n} can lead to
%% ambiguity.  For example
%% @example
%% @group
%% >> syms t
%% >> f = sin(t);
%% >> N = sym(50);
%% >> ezplot(f, double(N))  % plot f vs t using 50 pts
%%    @result{} ***
%% >> ezplot(f, N)          % Careful, parametric plot of f(t), N(t)
%%    @result{} ***
%% @end group
%% @end example
%% the solution, as above, is to convert the sym to a double.
%%
%% FIXME: Sept 2014, there are differences between Matlab
%% and Octave's ezplot and Matlab 2014a does not support N as
%% number of points.  Disabled some tests.
%%
%% @seealso{ezplot3, ezsurf, ezmesh, function_handle}
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

  firstsym = [];

  for i = (1+fshift):nargin
    if (isa(varargin{i}, 'sym'))
      if ( (i == 1 + fshift) || ...
           (i == 2 + fshift && isscalar(varargin{i})) ...
         )
        % This is one of the fcns to plot, so convert to handle fcn
        % The "i == 2" issscalar cond is to supports ezplot(f, sym([0 1]))

        % Each is function of one var, and its the same var for all
        thissym = symvar(varargin{i});
        assert(length(thissym) <= 1, ...
          'ezplot: plotting curves: functions should have at most one input');
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
            assert(logical(thissym == firstsym), ...
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


%!test
%! % simple
%! syms x
%! f = cos(x);
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = ezplot(f);
%! warning(s)
%! xx = get(h, 'xdata');
%! yy = get(h, 'ydata');
%! assert (abs(yy(end) - cos(xx(end))) <= 2*eps)
%! % matlab misses endpoint wtth nodisplay
%! %assert (abs(xx(end) - 2*pi) <= 4*eps)
%! %assert (abs(yy(end) - cos(2*pi)) <= 4*eps)

%!test
%! % parametric
%! syms t
%! x = cos(t);
%! y = sin(t);
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = ezplot(x, y);
%! warning(s)
%! xx = get(h, 'xdata');
%! assert (abs(xx(end) - cos(2*pi)) <= 4*eps)

%!error <all functions must be in terms of the same variables>
%! syms x t
%! ezplot(t, x)

%!error <functions should have at most one input>
%! syms x t
%! ezplot(t, t*x)

%%!test
%%! % contour, FIXME: broken on Matlab?  Issue #108
%%! syms x y
%%! f = sqrt(x*x + y*y) - 1;
%%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%%! h = ezplot(f);
%%! warning(s)
%%! y = get(h, 'ydata');
%%! assert (max(y) - 1 <= 4*eps)

%%!test
%%! % bounds etc as syms
%%! % FIXME: this number-of-points option no supported on matlab
%%! syms x
%%! f = cos(x);
%%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%%! h = ezplot(f, [0 2*sym(pi)], sym(42));
%%! warning(s)
%%! y = get(h, 'ydata');
%%! assert (length(y) == 42)
%%! assert (abs(y(end) - cos(4*pi)) <= 4*eps)

