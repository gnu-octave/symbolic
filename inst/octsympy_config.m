%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
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
%% @deftypefn {Function File} {@var{r} =} octsympy_config ()
%% Configure the octsympy system.
%%
%% FIXME: this should control unicode too.
%%
%% Example:
%% @example
%% octsympy_config ipc_default  % default, autodetected IPC
%% octsympy_config ipc_system   % use slow, but reliable (?) IPC
%% octsympy_config ipc_popen2   % force the popen2() ipc
%% w = octsympy_config('ipc')   % query the ipc mechanism
%% @end example
%%
%% @seealso{sym, syms, octsympy_reset}
%% @end deftypefn

function varargout = octsympy_config(cmd)

  persistent OCTSYMPY_CONFIG

  if (isempty(OCTSYMPY_CONFIG))
    OCTSYMPY_CONFIG = [];
    OCTSYMPY_CONFIG.ipc = 'default';
  end

  if (nargin == 0)
    varargout{1} = OCTSYMPY_CONFIG;
    return
  end


  switch lower(cmd)
    case 'ipc'
      varargout{1} = OCTSYMPY_CONFIG.ipc;

    case 'ipc_default'
      disp('Choosing the default octsympy communication mechanism [autodetect]');
      OCTSYMPY_CONFIG.ipc = 'default';
      octsympy_reset()
    case 'ipc_system'
      disp('Forcing the system() octsympy communication mechanism');
      OCTSYMPY_CONFIG.ipc = 'system';
      octsympy_reset()
    case 'ipc_popen2'
      disp('Forcing the popen2() octsympy communication mechanism');
      OCTSYMPY_CONFIG.ipc = 'popen2';
      octsympy_reset()
    otherwise
      error ('invalid input')
  end
end


%!assert(octsympy_config('ipc'), 'default')
