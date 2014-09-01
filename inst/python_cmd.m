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
%% @deftypefn  {Function File}  {[@var{a}, @var{b}, ...] =} python_cmd (@var{cmd}, @var{x}, @var{y}, ...)
%% Run some Python command on some objects and return other objects.
%%
%% Here @var{cmd} is a string of Python code.
%% Inputs @var{x}, @var{y}, ... can be a variety of objects
%% (possible types listed below). Outputs @var{a}, @var{b}, ... are
%% converted from Python objects: not all types are possible, see
%% below.
%%
%% Example:
%% @example
%% cmd = '(x,y) = _ins; return (x+y,x-y)';
%% [a,b] = python_cmd (cmd, x, y);
%% % now a == x + y and b == x - y
%% @end example
%%
%% The inputs will be in a list called '_ins'.  The command should
%% end by outputing a tuple of return arguments.
%% If you have just one return value, you probably want to append
%% an extra comma.  Either of these approaches will work:
%% @example
%% cmd = '(x,y) = _ins; return (x+y,)'
%% cmd = '(x,y) = _ins; return x+y,'
%% a = python_cmd (cmd, x, y)
%% @end example
%% (Python gurus will know why).
%%
%% Instead of @code{return}, you can append to the Python list
%% @code{_outs}@:
%% @example
%% cmd = '(x,y) = _ins; _outs.append(x**y)'
%% a = python_cmd (cmd, x, y)
%% @end example
%%
%% The string can have newlines for longer commands but be careful
%% with whitespace: its Python!
%% @example
%% cmd = [ '(x,) = _ins\n'  ...
%%         'if x.is_Matrix:\n'  ...
%%         '    return ( x.T ,)\n' ...
%%         'else:\n' ...
%%         '    return ( x ,)' ];
%% @end example
%% It might be a good idea to avoid blank lines (FIXME: this used to
%% be a problem, can't reproduce).
%%
%% Possible input types:
%%    sym objects;
%%    strings (char);
%%    scalar doubles.
%% They can also be cell arrays of these items.  Multi-D cell
%% arrays may not work properly.
%%
%% Possible output types:
%%    SymPy objects (Matrix and Expr at least);
%%    int;
%%    float;
%%    string;
%%    unicode strings;
%%    bool;
%%    dict (converted to structs);
%%    lists/tuples (converted to cell vectors).
%%
%% FIXME: add a py_config to change the header?  The python
%% environment is defined in python_header.py.  Changing it is
%% currently harder than it should be.
%%
%% Note: if you don't pass in any sym's, this shouldn't need SymPy.
%% But it still imports it in that case.  If  you want to run this
%% w/o having the SymPy package, you'd need to hack a bit.
%%
%% @seealso{evalpy}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: python

function varargout = python_cmd(cmd, varargin)

  newl = sprintf('\n');

  if (iscell(cmd))
    %% each cell is a line
    % this way, also could escape ", others?

    % newlines and indented except first line
    %cmd = mystrjoin(cmd, [newl '    ']);
  else
    %% Legacy mode: one big string
    % The user might or might not have escaped newlines in the command.
    % We want to reliably indent this code to put it in a Python function.
    % so we pass it through sprintf: trouble: this expands \n to newlines within string consts
    % as well as the line endings.  Also, we add spaces: yuck!
    cmd = strrep(cmd, '\n', newl);
    cmd = strtrim(cmd);  % don't want trailing newlines
    cmd = mystrsplit(cmd, {newl});
    %cmd = strrep(cmd, newl, [newl '    ']);  % indent each line by 4
  end


  %% IPC interface
  % the ipc mechanism shall put the input variables in the tuple
  % '_ins' and it will return to us whatever we put in the tuple
  % '_outs'.  There is no particular reason this needs to define
  % a function, I just thought it isolates local variables a bit.
  cmd = indent_lines(cmd, 4);
  cmd = { 'def _fcn(_ins):' ...
          '    _outs = []' ...
          cmd{:} ...
          '    return _outs' ...
          '_outs = _fcn(_ins)' };

  [A, db] = python_ipc_driver('run', cmd, varargin{:});
  % FIXME: filter this earlier?
  A = A{1};
  %db

  M = length(A);
  varargout = cell(1,M);
  for i=1:M
    varargout{i} = A{i};
  end

  if nargout ~= M
    warning('number of outputs don''t match, was this intentional?')
  end
end


%!test
%! % general test
%! x = 10; y = 6;
%! cmd = '(x,y) = _ins; return (x+y,x-y)';
%! [a,b] = python_cmd (cmd, x, y);
%! assert (a == x + y && b == x - y)

%!test
%! % bool
%! assert (python_cmd ('return True,'))
%! assert (~python_cmd ('return False,'))

%!test
%! % float
%! assert (abs(python_cmd ('return 1.0/3,') - 1/3) < 1e-15)

%!test
%! % int
%! assert (python_cmd ('return 123456,') == 123456)

%!test
%! % string
%! x = 'octave';
%! cmd = 's = _ins[0]; return s.capitalize(),';
%! y = python_cmd (cmd, x);
%! assert (strcmp(y, 'Octave'))

%!test
%! % string with newlines
%! x = 'a string\nbroke off\nmy guitar\n';
%! x2 = sprintf('a string\nbroke off\nmy guitar\n');
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x2))

%%!xtest
%%! % bug: cmd string with newlines
%%! y = python_cmd ('return "string\nbroke",')
%%! y2 = 'string\nbroke'
%%! assert (strcmp(y, y2))

%%!test
%%! % FIXME: newlines: should be escaped for import?
%%! x = 'a string\nbroke off\nmy guitar\n';
%%! x2 = sprintf('a string\nbroke off\nmy guitar\n');
%%! y = python_cmd ('return _ins', x2);
%%! assert (strcmp(y, x2))

%!test
%! % string with XML escapes
%! x = '<> >< <<>>';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))
%! x = '&';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % strings with double quotes
%! % maybe its sensible to need to escape double-quotes to send to python?
%! % FIXME: or we could escape ", \, \n automatically?
%! x = 'a\"b\"c';
%! expy = 'a"b"c';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, expy))
%! x = '\"';
%! expy = '"';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, expy))

%!test
%! % strings with quotes
%! x = 'a''b';  # this is a single quote
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % strings with quotes
%! x = '\"a''b\"c''\"d';
%! y1 = '"a''b"c''"d';
%! cmd = 's = _ins[0]; return s,';
%! y2 = python_cmd (cmd, x);
%! assert (strcmp(y1, y2))

%!test
%! % strings with printf escapes
%! x = '% %% %%% %%%% %s %g %%s';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % slashes: FIXME: escape backslashes
%! x = '/\\ // \\\\ \\/\\/\\';
%! z = '/\ // \\ \/\/\';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, z))

%!test
%! % strings with special chars
%! x = '!@#$^&* you!';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))
%! x = '~-_=+[{]}|;:,.?';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!xtest
%! % string with backtick trouble for system -c (sysoneline)
%! x = '`';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % unicode
%! s1 = '我爱你';
%! cmd = 'return u"\u6211\u7231\u4f60",';
%! s2 = python_cmd (cmd);
%! assert (strcmp (s1,s2))

%%!test
%%! % unicode passthru: FIXME: how to get unicode back to Python?
%%! s1 = '我爱你'
%%! cmd = 'return (_ins[0],)';
%%! s2 = python_cmd (cmd, s1)
%%! assert (strcmp (s1,s2))

%%!test
%%! % unicode w/ slashes, escapes, etc  FIXME
%%! s1 = '我爱你<>\\&//\\#%% %\\我'
%%! s3 = '我爱你<>\&//\#%% %\我'
%%! cmd = 'return u"\u6211\u7231\u4f60",';
%%! s2 = python_cmd (cmd)
%%! assert (strcmp (s2,s3))

%!test
%! % list, tuple
%! assert (isequal (python_cmd ('return [1,2,3],'), {1, 2, 3}))
%! assert (isequal (python_cmd ('return (4,5),'), {4, 5}))
%! assert (isequal (python_cmd ('return (6,),'), {6,}))
%! assert (isequal (python_cmd ('return [],'), {}))

%!test
%! % dict
%! cmd = 'd = dict(); d["a"] = 6; d["b"] = 10; return d,';
%! d = python_cmd (cmd);
%! assert (d.a == 6 && d.b == 10)
