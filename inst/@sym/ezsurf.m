%% Copyright (C) 2016-2017, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym ezsurf (@var{z})
%% @defmethodx @@sym ezsurf (@var{f1}, @var{f2}, @var{f3})
%% @defmethodx @@sym ezsurf (@dots{}, @var{dom})
%% @defmethodx @@sym ezsurf (@dots{}, @var{N})
%% Simple 3D surface plots of symbolic expressions.
%%
%% Example 3D surface plot:
%% @example
%% @group
%% syms x y
%% z = sin(2*x)*sin(y)
%%   @result{} z = (sym) sin(2⋅x)⋅sin(y)
%% ezsurf(z)                                    % doctest: +SKIP
%% @end group
%% @end example
%%
%% Example parametric surface plot of a Möbius strip:
%% @example
%% @group
%% syms u v
%% x = (1+v*cos(u/2))*cos(u)
%%   @result{} x = (sym)
%%       ⎛     ⎛u⎞    ⎞
%%       ⎜v⋅cos⎜─⎟ + 1⎟⋅cos(u)
%%       ⎝     ⎝2⎠    ⎠
%% y = (1+v*cos(u/2))*sin(u);
%% z = v*sin(u/2);
%%
%% ezsurf(x, y, z, [0 2*pi -0.5 0.5], 32)       % doctest: +SKIP
%% axis equal
%% @end group
%% @end example
%%
%% See help for the (non-symbolic) @code{ezsurf}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% @seealso{ezsurf, @@sym/ezmesh, @@sym/ezplot, @@sym/function_handle}
%% @end defmethod


function varargout = ezsurf(varargin)

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
        assert(length(thissym) <= 2, ...
          'ezsurf: parameterized: functions should have at most two inputs');
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
            assert(all(logical(thissym == firstsym)), ...
              'ezsurf: all functions must be in terms of the same variables');
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

  h = ezsurf(varargin{:});

  if (nargout)
    varargout{1} = h;
  end

end


%!error <all functions must be in terms of the same variables>
%! syms u v t
%! ezsurf(u*v, 2*u*v, 3*v*t)

%!error <functions should have at most two inputs>
%! syms u v t
%! ezsurf(u*v, 2*u*v, u*v*t)
