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
%% @deftypefn  {Function File} {@var{h} =} ezplot3 (@var{f1}, @var{f2},@var{f3})
%% @deftypefnx {Function File} {@var{h} =} ezplot (...)
%% Simple 3D parametric plotting of symbolic expressions.
%%
%% See help for the (non-symbolic) @code{ezplot3}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% @seealso{ezplot, ezsurf, ezmesh, matlabFunction}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, plotting

function varargout = ezplot3(varargin)

  % first input is handle, shift
  if (ishandle(varargin{1}))
    firstpotsym = 2;
  else
    firstpotsym = 1;
  end

  maxnumsym = 3;

  for i = firstpotsym:nargin
    if (isa(varargin{i}, 'sym'))
      if (i < firstpotsym + maxnumsym)
        % one of the fcns to plot, covert to handle fcn
        varargin{i} = matlabFunction(varargin{i});
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


%!test
%! % parametric
%! syms t
%! f1 = cos(t);
%! f2 = sin(t);
%! f3 = t;
%! h = ezplot3(f1, f2, f3);
%! zz = get(h, 'zdata');
%! assert (abs(zz(end) - 2*pi) <= 4*eps)

%!test
%! % bounds etc as syms
%! syms t
%! f1 = cos(t);
%! f2 = sin(t);
%! f3 = t;
%! h = ezplot3(f1, f2, f3, [sym(0) sym(pi)], sym(42));
%! zz = get(h, 'zdata');
%! assert (length(zz) == 42)
%! assert (abs(zz(end) - pi) <= 4*eps)

