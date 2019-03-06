%% Copyright (C) 2017 Colin B. Macdonald
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
%% @defmethod  @@sym ezcontour (@var{f})
%% @defmethodx @@sym ezcontour (@dots{}, @var{dom})
%% @defmethodx @@sym ezcontour (@dots{}, @var{N})
%% Simple contour plots of symbolic expressions.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% z = sin(2*x)*sin(y)
%%   @result{} z = (sym) sin(2⋅x)⋅sin(y)
%% @c doctest: +SKIP
%% ezcontour(z)
%% @end group
%% @end example
%%
%% See help for the (non-symbolic) @code{ezcontour}, which this
%% routine calls after trying to convert sym inputs to
%% anonymous functions.
%%
%% @seealso{ezcontour, @@sym/ezsurf, @@sym/function_handle}
%% @end defmethod


function varargout = ezcontour(varargin)

  % first input is handle, shift
  if (ishandle (varargin{1}))
    i = 2;
  else
    i = 1;
  end

  assert (isa (varargin{i}, 'sym'))
  vars = symvar (varargin{i});
  assert (length (vars) <= 2, ...
          'ezcontour: function must have at most two inputs');
  if (isempty (vars) || ...
      (length (vars) == 1 && isequal (vars, sym('x'))) || ...
      (length (vars) == 1 && isequal (vars, sym('y'))))
    %% special treatment and ordering for x, y
    vars = [sym('x') sym('y')];
  end
  varargin{i} = function_handle (varargin{i}, 'vars', vars);

  for i = (i+1):nargin
    if (isa (varargin{i}, 'sym'))
      %% plot ranges, etc: convert syms to doubles
      varargin{i} = double (varargin{i});
    end
  end

  h = ezcontour (varargin{:});

  if (nargout)
    varargout{1} = h;
  end

end


%!error <at most two inputs>
%! syms x y z
%! ezcontour (x*y*z)
