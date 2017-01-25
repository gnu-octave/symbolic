%% Copyright (C) 2016-2017 Colin B. Macdonald
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
%% @defun octassert (@var{a},@var{b},@var{tol})
%% Wrapper for assert on Matlab.
%%
%% Octave's @code{assert} has this three-input version
%% for testing either abs or rel tol.  This only supports
%% scalar @var{tol}: Octave can have a vector there.
%% @end defun

function octassert (varargin)

  if (exist ('OCTAVE_VERSION', 'builtin'))
    warning('why are you calling this on Octave?  No need...')
  end

  if (nargin == 1)
    assert(varargin{1});
    return
  elseif (nargin == 2)
    tol = 0;
  elseif (nargin == 3)
    tol = varargin{3};
  else
    error('no such assert call with 4 inputs?')
  end

  a = varargin{1};
  b = varargin{2};
  a = a(:);
  b = b(:);
  assert (isscalar (tol))
  if (tol < 0)
    % rel error
    assert (all (abs (a - b) <= abs (tol)*abs (b)))
  else
    % abs error
    assert (all (abs (a - b) <= abs (tol)))
  end

end
