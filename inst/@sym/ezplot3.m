%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod  @@sym ezplot3 (@var{f1}, @var{f2}, @var{f3})
%% @defmethodx @@sym ezplot3 (@dots{}, @var{dom})
%% @defmethodx @@sym ezplot3 (@dots{}, @var{N})
%% Simple 3D parametric plotting of symbolic expressions.
%%
%% Example parametric plot of a spiral:
%% @example
%% @group
%% syms t
%% x = t*cos(10*t), y = t*sin(10*t), z = t
%%   @result{} x = (sym) t⋅cos(10⋅t)
%%   @result{} y = (sym) t⋅sin(10⋅t)
%%   @result{} z = (sym) t
%%
%% ezplot3(x, y, z)                             % doctest: +SKIP
%% @end group
%% @end example
%%
%% See help for the (non-symbolic) @code{ezplot3}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% @seealso{ezplot3, @@sym/ezplot, @@sym/ezsurf, @@sym/function_handle}
%% @end defmethod


function varargout = ezplot3(varargin)

  % first input is handle, shift
  if (ishandle(varargin{1}))
    firstpotsym = 2;
  else
    firstpotsym = 1;
  end

  maxnumsym = 3;
  firstsym = [];

  for i = firstpotsym:nargin
    if (isa(varargin{i}, 'sym'))
      if (i < firstpotsym + maxnumsym)
        % one of the fcns to plot, covert to handle fcn

        % Each is function of one var, and its the same var for all
        thissym = symvar(varargin{i});
        assert(length(thissym) <= 1, ...
          'ezplot3: plotting curves: functions should have at most one input');
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
              'ezplot3: all functions must be in terms of the same variables');
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

  h = ezplot3(varargin{:});

  if (nargout)
    varargout{1} = h;
  end

end


%%!shared hf
%%! % offscreen rendering currently (2016-06) causing crashes:
%%! % e.g., https://savannah.gnu.org/bugs/?44478
%%! hf = figure ('visible', 'off');

%!test
%! % parametric
%! syms t
%! f1 = cos(t);
%! f2 = sin(t);
%! f3 = t;
%! h = ezplot3(f1, f2, f3);
%! zz = get(h, 'zdata');
%! assert (abs(zz(end) - 2*pi) <= 4*eps)

%!error <all functions must be in terms of the same variables>
%! syms x t
%! ezplot3(t, x, t)

%!error <functions should have at most one input>
%! syms x t
%! ezplot3(t, t*x, t)

%!test
%! % bounds etc as syms
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! % disabled for matlab, see ezplot.m too
%! syms t
%! f1 = cos(t);
%! f2 = sin(t);
%! f3 = t;
%! h = ezplot3(f1, f2, f3, [sym(0) sym(pi)], sym(42));
%! zz = get(h, 'zdata');
%! assert (length(zz) == 42)
%! assert (abs(zz(end) - pi) <= 4*eps)
%! end

%!test
%! close all

%%!test
%%! close (hf)
