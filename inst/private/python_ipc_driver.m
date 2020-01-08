%% Copyright (C) 2014-2016, 2019-2020 Colin B. Macdonald
%% Copyright (C) 2017 Mike Miller
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
%% @deftypefun {[@var{A}, @var{db}] =} python_ipc_driver (@dots{})
%% Private function: run Python/SymPy command and return objects.
%%
%% @var{A} is the resulting object, which might be an error code.
%%
%% @var{db} usually contains diagnostics to help with debugging
%% or error reporting.
%% @end deftypefun

function [A, db] = python_ipc_driver(what, cmd, varargin)

  which_ipc = sympref('ipc');

  %% version check
  if exist('OCTAVE_VERSION', 'builtin')
    if (compare_versions (OCTAVE_VERSION (), '4.2', '<'))
      fprintf(['\n********************************************************************\n' ...
               'Your Octave version is %s but Octsympy is currently untested on\n' ...
               'anything before 4.2.\n\n'], OCTAVE_VERSION ())
      warning('Old Octave version detected: probably trouble ahead!')
      fprintf('\n********************************************************************\n\n')
      fflush(stdout);
    end
  end

  if (strcmp(lower(which_ipc), 'default'))
    % TODO: may need to adjust, ideally just 'py'
    if (exist ('pyversion') && exist ('pyexec') && exist ('pyeval'))
      which_ipc = 'native';
    elseif (exist ('popen2') > 1)
      which_ipc = 'popen2';
    else
      which_ipc = 'system';
    end
  end

  switch lower(which_ipc)
    case 'native'
      [A, db] = python_ipc_native(what, cmd, varargin{:});

    case 'popen2'
      [A, db] = python_ipc_popen2(what, cmd, varargin{:});

    case 'system'
      if (ispc () && (~isunix ()))
        [A, db] = python_ipc_sysoneline(what, cmd, false, varargin{:});
      else
        [A, db] = python_ipc_system(what, cmd, false, varargin{:});
      end

    case 'systmpfile'
      %% for debugging, not intended for long-term usage
      [A, db] = python_ipc_system(what, cmd, true, varargin{:});

    case 'sysoneline'
      %% for debugging, not intended for long-term usage
      [A, db] = python_ipc_sysoneline(what, cmd, false, varargin{:});

    otherwise
      if (strcmp (what, 'reset'))
        A = true;
        db = [];
      else
        error ('invalid ipc mechanism')
      end
  end
