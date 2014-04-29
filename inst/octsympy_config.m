%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn {Function File} {@var{r} =} octsympy_config ()
%% Configure the octsympy system.
%%
%% FIXME: this should control unicode too.
%%
%% Communication mechanism:
%% @example
%% octsympy_config ipc default   % default, autodetected
%% octsympy_config ipc system    % slow, but maybe more robust?
%% octsympy_config ipc popen2    % force the popen2() ipc
%% w = octsympy_config('ipc')    % query the ipc mechanism
%% @end example
%%
%% Snippets: when displaying a sym object, we show the first
%% few characters of the SymPy string representation.
%% @example
%% octsympy_config snippet 1|0   % or true/false
%% @end example
%%
%% @seealso{sym, syms, octsympy_reset}
%% @end deftypefn

function varargout = octsympy_config(cmd, arg)

  persistent settings

  if (isempty(settings))
    settings = 42;
    octsympy_config('defaults')
  end

  if (nargin == 0)
    varargout{1} = settings;
    return
  end


  switch lower(cmd)
    case 'defaults'
      settings = [];
      settings.ipc = 'default';
      settings.snippet = true;

    case 'snippet'
      if (nargin == 1)
        varargout{1} = settings.snippet;
      elseif ischar(arg)
        settings.snippet = strcmp(arg, 'true');
      else
        settings.snippet = logical(arg);
      end

    case 'ipc'
      if (nargin == 1)
        varargout{1} = settings.ipc;
      else
        octsympy_reset()
        settings.ipc = arg;
        switch arg
          case 'default'
            disp('Choosing the default [autodetect] octsympy communication mechanism')
          case 'system'
            disp('Forcing the system() octsympy communication mechanism')
          case 'popen2'
            disp('Forcing the popen2() octsympy communication mechanism')
          otherwise
          warning(['Unknown IPC mechanism: hope you know what you''re doing'])
        end
      end

    otherwise
      error ('invalid input')
  end
end


%!test
%! octsympy_config('defaults')
%! assert(octsympy_config('ipc'), 'default')
