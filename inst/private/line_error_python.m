%% Copyright (C) 2016 Lagu
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

function r = line_error_python(a = 'set')

  persistent linerror;

  if strcmp(a, 'get')
    if isempty(linerror)
      line_error_python;
    end
    r = linerror;
    return;
  else
    cmd = { 'def _fcn(_ins):' ...
            '    _outs = []' ...
            '    try:' ...
            '        raise NameError' ...
            '        return _outs' ...
            '    except Exception as e:' ...
            '        exc_type, exc_obj, tb = sys.exc_info()' ...
            '        return sys.exc_info()[-1].tb_lineno' ...
            '_outs = _fcn(_ins)'
          };

    [A, db] = python_ipc_driver('run', cmd);
    linerror = A - 1;
  end
end
