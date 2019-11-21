%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defun  evalpy (@var{cmd})
%% @defunx evalpy (@var{cmd}, @var{x}, @var{y}, @dots{})
%% Run Python code, automatically transferring results.
%%
%% @strong{Note} this function is @emph{deprecated}.
%% @example
%% @comment doctest: -TEXINFO_SKIP_BLOCKS_WO_OUTPUT
%% s = warning ('off', 'OctSymPy:deprecated');
%% @end example
%%
%% Examples:
%% @example
%% @group
%% x = -4;
%% evalpy ('y = 2*x', x)
%%   @print{} y = -8
%% y
%%   @result{} y = -8
%% @end group
%% @end example
%%
%% You can replace @code{x} with a new value in the Python code:
%% @example
%% @group
%% syms x
%% evalpy ('y = 3*x; x = -1.5; z = x**2', x)
%%   @print{} x = -1.5000
%%   @print{} y = (sym) 3⋅x
%%   @print{} z =  2.2500
%% @end group
%% @end example
%%
%% All arguments can be accessed as @code{i0}, @code{i1}, etc.
%% This is useful if they don't have inputnames:
%% @example
%% @group
%% x = 10;
%% evalpy ('y = ", ".join( (str(x),str(i0),str(i1)) )', x, 5)
%%   @print{} y = 10.0, 10.0, 5.0
%% @end group
%% @end example
%%
%% If you need a variable in Python but don't want it passed back
%% to Octave, put an @code{_} (underscore) at the beginning or end.
%% @example
%% @group
%% x = 20;
%% evalpy ('_y = 3*x; z_ = _y/6; my = z_/2;', x)
%%   @print{} Variables effected: my
%% _y   @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%%   @print{} ??? '_y' undefined near line 1, column 1
%% z_   @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%%   @print{} ??? 'z_' undefined near line 1, column 1
%% warning (s);
%% @end group
%% @end example
%%
%% The final few characters of @var{cmd} effect the verbosity:
%% @itemize
%% @item 2 semicolons @code{;;}, very quiet, no output.
%% @item 1 semicolon @code{;}, a one-line msg about variables assigned.
%% @item no semicolon, display each variable assigned.
%% @end itemize
%%
%% Multiline code should be placed in a cell array, see the
%% @code{pycall_sympy__} documentation.
%%
%% Warning: evalpy is probably too smart for its own good.  It is
%% intended for interactive use.  In your non-interactive code, you
%% might want @code{pycall_sympy__} instead.
%%
%% Notes:
%% @itemize
%% @item if you assign to @var{x} but don't change its value,
%%   it will not be assigned to and will not appear in the
%%   ``Variables effected'' list.
%% @item using print is probably a bad idea.  For now, use
%%   @code{dbout(x)} to print @code{x} to stderr which should
%%   appear in the terminal (FIXME: currently broken on windows).
%% @item evalpy is a bit of a work-in-progress and subject to
%%   change.  For example, with a proper IPC mechanism, you could
%%   grab the values of @var{x} etc when needed and not need to
%%   specify them as args.
%% @end itemize
%%
%% @seealso{pycall_sympy__}
%% @end defun


function evalpy(cmd, varargin)

  warning('OctSymPy:deprecated', 'evalpy is deprecated')

  %% import variables
  % use name of input if it has one, also i0, i1, etc
  s = {};
  for i = 1:(nargin-1)
    s{end+1} = sprintf('i%d = _ins[%d]', i-1, i-1);
    name = inputname(i+1);
    if ~isempty(name)
      s{end+1} = sprintf('%s = _ins[%d]', name, i-1);
      s{end+1} = sprintf('_%s_orig = copy.copy(%s)', name, name);
    end
  end
  vars2py = s;


  %% generate code which checks if inputs have changed
  s = {};
  for i = 1:(nargin-1)
    name = inputname(i+1);
    if ~isempty(name)
      s{end+1} = sprintf('if not %s == _%s_orig:', name, name);
      s{end+1} = sprintf('    _newvars["%s"] = %s', name, name);
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
  if ~iscell(cmd)
    cmd = {cmd};
  end
  % count semicolons
  s = cmd{end};
  if strcmp(s(end-1:end),';;')
    verbosity = 0;
    cmd{end} = s(1:end-1);  % ;; is syntax error in python
  elseif s(end) == ';'
    verbosity = 1;
  else
    verbosity = 2;
  end


  fullcmd = { ...
      vars2py{:} ...
      '_vars1 = locals().copy()' ...
      cmd{:} ...
      '_vars2 = locals().copy()' ...
      '_newvars = dictdiff(_vars2, _vars1)' ...
      changed_vars_also_export{:} ...
      '_names = []' ...
      'for key in _newvars:' ...
      '    if not (key[0] == "_" or key[-1] == "_"):' ...
      '        _outs.append(_vars2[key])' ...
      '        _names.append(key)' ...
      'return (_names,_outs,)' };

  %% debugging
  %fprintf('\n*** <CODE> ***\n')
  %disp(fullcmd)
  %fprintf('\n*** </CODE> ***\n\n')

  [names, values] = pycall_sympy__ (fullcmd, varargin{:});
  assert (length(names) == length(values))

  % Make the visual display of the results deterministic.  Not easy to
  % use OrderedDict in Python because `locals()` is a regular dict.
  [names, I] = sort(names);
  values = values(I);

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
%! s = warning ('off', 'OctSymPy:deprecated');
%! x = 6;
%! evalpy('y = 2*x;;', x);
%! assert( y == 12 )
%! warning (s)

%!test
%! s = warning ('off', 'OctSymPy:deprecated');
%! x = 6;
%! evalpy('y = 2*x; x = 10; z = 3*x;;', x);
%! assert( isequal( [x y z], [10 12 30] ))
%! warning (s)

%% underscore variables not returned
%!test
%! s = warning ('off', 'OctSymPy:deprecated');
%! evalpy('_y = 42; x_ = 42');
%! assert( ~exist('_y', 'var'))
%! assert( ~exist('x_', 'var'))
%! warning (s)

%!test
%! s = warning ('off', 'OctSymPy:deprecated');
%! evalpy('_y = "GNU Octave Rocks"; z = _y.split();;');
%! assert( iscell(z) )
%! assert( isequal (z, {'GNU', 'Octave','Rocks'} ))
%! warning (s)
