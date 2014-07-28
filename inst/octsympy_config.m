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
%% @deftypefn {Function File} {@var{r} =} octsympy_config ()
%% Configure the octsympy system.
%%
%% Communication mechanism:
%% @example
%% octsympy_config ipc default   % default, autodetected
%% octsympy_config ipc system    % slow, but maybe more robust?
%% octsympy_config ipc popen2    % force the popen2() ipc
%% w = octsympy_config('ipc')    % query the ipc mechanism
%% @end example
%%
%% Python executable path/command:
%% @example
%% octsympy_config python '/usr/bin/python'
%% octsympy_config python 'C:\Python\python.exe'
%% octsympy_config python 'N:\myprogs\py.exe'
%% @end example
%% Default is an empty string; in which case octsympy just runs
%% @code{python} and assumes the path is set appropriately.
%% FIXME: need to make sure default works on Windows too.
%%
%% Snippets: when displaying a sym object, we show the first
%% few characters of the SymPy string representation.
%% @example
%% octsympy_config snippet 1|0   % or true/false
%% @end example
%%
%% FIXME: Unicode support: use unicode for displaying syms.
%% @example
%% octsympy_config unicode 1|0   % or true/false
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
      settings.unicode = true;
      settings.snippet = true;
      settings.whichpython = '';

    case 'unicode'
      if (nargin == 1)
        varargout{1} = settings.unicode;
      else
        settings.unicode = tf_from_input(arg);
      end

    case 'snippet'
      if (nargin == 1)
        varargout{1} = settings.snippet;
      else
        settings.snippet = tf_from_input(arg);
      end

    case 'python'
      if (nargin == 1)
        varargout{1} = settings.whichpython;
      elseif (isempty(arg) || strcmp(arg,'[]'))
        settings.whichpython = '';
        octsympy_reset()
      else
        settings.whichpython = arg;
        octsympy_reset()
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


function r = tf_from_input(s)

  if (~ischar(s))
    r = logical(s);
  elseif (strcmpi(s, 'true'))
    r = true;
  elseif (strcmpi(s, 'false'))
    r = false;
  elseif (strcmpi(s, '[]'))
    r = false;
  else
    r = str2double(s);
    assert(~isnan(r), 'invalid expression to convert to bool')
    r = logical(r);
  end
end


%!test
%! octsympy_config('defaults')
%! assert(strcmp(octsympy_config('ipc'), 'default'))
