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
%% @deftypefn  {Function File} {} evalpy (@var{cmd})
%% @deftypefnx {Function File} {} evalpy (@var{cmd}, @var{x}, @var{y}, ...)
%% Run Python code, automatically transferring results.
%%
%% Examples:
%% @example
%% clear y
%% x = 4
%% evalpy ('y = 2*x', x)
%% y   % y is now 8
%% @end example
%%
%% You can replace x with a new value in the Python code:
%% @example
%% syms x
%% evalpy ('y = 3*x; x = 1.5; z = x**2', x)
%% x   % 1.5  (double)
%% y   % 3*x  (sym)
%% z   % 2.25 (double)
%% @end example
%%
%% All arguments can be accessed as @code{i0}, @code{i1}, etc.
%% This is useful if they don't have inputnames:
%% @example
%% x = 10
%% evalpy ('y = " ".join( (str(x),str(i0),str(i1)) )', x, 5)
%% y = '10 10 5'
%% @end example
%%
%% If you need a variable in Python but don't want it passed back
%% to Octave, put an @code{_} (underscore) at the beginning or end.
%% @example
%% x = 20
%% evalpy ('_y = 3*x; z_ = _y/6; my = z_/2;', x)
%% my      % 5
%% _y, z_  % error, undefined
%% @end example
%%
%% The final few characters of @var{cmd} effect the verbosity:
%% @itemize
%% @item 2 semicolons @code{;;}, very quiet, no output.
%% @item 1 semicolon @code{;}, a one-line msg about variables assigned.
%% @item no semicolon, display each variable assigned.
%% @end itemize
%%
%% Warning: evalpy is probably too smart for its own good.  It is
%% intended for interactive use.  In your non-interactive code, you
%% might want @code{python_cmd} instead.
%%
%% Notes:
%% @itemize
%% @item if you assign to @var{x} but don't change its value,
%%   it will not be assigned to and will not appear in the
%%   Variables effected:" list.
%% @item using print is probably a bad idea.  For now, use
%%   @code{dbout(x)} to print @code{x} to stderr which should
%%   appear in the terminal (FIXME).
%% @item evalpy is a bit of a work-in-progress and subject to
%%   change.  For example, with a proper IPC mechanism, you could
%%   grab the values of @var{x} etc when needed and not need to
%%   specify them as args.
%% @end itemize
%%
%% @seealso{python_cmd}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: python

function evalpy(cmd, varargin)

  %% import variables
  % use name of input if it has one, also i0, i1, etc
  s = '';
  j = 0;
  for i = 1:(nargin-1)
    s = sprintf('%si%d = _ins[%d]\n', s, i-1, i-1);
    name = inputname(i+1);
    if ~isempty(name)
      s = sprintf('%s%s = _ins[%d]\n', s, name, i-1);
      s = sprintf('%s_%s_orig = %s\n', s, name, name);
    end
  end
  vars2py = s;


  %% generate code which checks if inputs have changed
  s = '';
  for i = 1:(nargin-1)
    name = inputname(i+1);
    if ~isempty(name)
      s = sprintf('%sif not %s == _%s_orig:\n', s, name, name);
      s = sprintf('%s    _newvars["%s"] = %s\n', s, name, name);
    end
  end
  changed_vars_also_export = s;

  %s = '';
  %e = findstr(cmd, '=')
  %for i = 1:length(e);
  %  n = e(i);
  %  cmd(n)
  %end

  %% Examine end of cmd
  % strip newline from end of cmd, and any leading/trailing whitespace
  cmd = sprintf(cmd);  % ensure we printf the cmd to unescape newlines
  cmd = strtrim(cmd);
  if strcmp(cmd(end-1:end),';;')
    verbosity = 0;
    cmd = cmd(1:end-1);  % ;; is syntax error in python
  elseif cmd(end) == ';'
    verbosity = 1;
  else
    verbosity = 2;
  end

  fullcmd = [ ...
      vars2py ...
      '_vars1 = locals().copy()\n' ...
      cmd  '\n' ...
      '_vars2 = locals().copy()\n' ...
      '_newvars = dictdiff(_vars2, _vars1)\n' ...
      changed_vars_also_export ...
      '_names = []\n' ...
      'for key in _newvars:\n' ...
      '    if not (key[0] == "_" or key[-1] == "_"):\n' ...
      '        _outs.append(_vars2[key])\n' ...
      '        _names.append(key)\n' ...
      'return (_names,_outs,)' ];

  %% debugging
  %fprintf('\n*** <CODE> ***\n')
  %fprintf(fullcmd)
  %fprintf('\n*** </CODE> ***\n\n')

  [names,values] = python_cmd (fullcmd, varargin{:});
  assert (length(names), length(values))

  %fprintf('assigning to %s...\n', names{i})
  for i=1:length(names)
    assignin('caller', names{i}, values{i})
    if (verbosity >= 2)
      evalin('caller', names{i})
    end
    if (i==1)
      varnames = names{i};
    else
      varnames = [varnames ', ' names{i}];
    end
  end
  if (verbosity == 1)
    if (length(names) == 0)
      fprintf('no variables changed\n');
    else
      fprintf('Variables effected: %s\n', varnames);
    end
  end
end


%!test
%! x = 6;
%! evalpy('y = 2*x;;', x);
%! assert( y == 12 )

%!test
%! x = 6;
%! evalpy('y = 2*x; x = 10; z = 3*x;;', x);
%! assert( [x y z], [10 12 30] )

%% underscore variables not returned
%!test
%! evalpy('_y = 42; x_ = 42');
%! assert( ~exist('_y', 'var'))
%! assert( ~exist('x_', 'var'))

%!test
%! evalpy('_y = "GNU Octave Rocks"; z = _y.split();;');
%! assert( iscell(z) )
%! assert( z, {'GNU', 'Octave','Rocks'} )

