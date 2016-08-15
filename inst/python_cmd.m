%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @deftypefun {[@var{a}, @var{b}, @dots{}] =} python_cmd (@var{cmd}, @var{x}, @var{y}, @dots{})
%% Run some Python command on some objects and return other objects.
%%
%% Here @var{cmd} is a string of Python code.
%% Inputs @var{x}, @var{y}, @dots{} can be a variety of objects
%% (possible types listed below). Outputs @var{a}, @var{b}, @dots{} are
%% converted from Python objects: not all types are possible, see
%% below.
%%
%% Example:
%% @example
%% @group
%% x = 10; y = 2;
%% cmd = '(x, y) = _ins; return (x+y, x-y)';
%% [a, b] = python_cmd (cmd, x, y)
%%   @result{} a =  12
%%   @result{} b =  8
%% @end group
%% @end example
%%
%% The inputs will be in a list called '_ins'.
%% Instead of @code{return}, you can append to the Python list
%% @code{_outs}:
%% @example
%% @group
%% cmd = '(x, y) = _ins; _outs.append(x**y)';
%% a = python_cmd (cmd, x, y)
%%   @result{} a =  100
%% @end group
%% @end example
%%
%% If you want to return a list, one way to to append a comma
%% to the return command.  Compare these two examples:
%% @example
%% @group
%% L = python_cmd ('return [1, -3.4, "python"],')
%%   @result{} L =
%%     @{
%%       [1,1] =  1
%%       [1,2] = -3.4000
%%       [1,3] = python
%%     @}
%% [a, b, c] = python_cmd ('return [1, -3.4, "python"]')
%%   @result{} a =  1
%%   @result{} b = -3.4000
%%   @result{} c = python
%% @end group
%% @end example
%%
%% You can also pass a cell-array of lines of code.  But be careful
%% with whitespace: its Python!
%% @example
%% @group
%% cmd = @{ '(x,) = _ins'
%%         'if x.is_Matrix:'
%%         '    return x.T'
%%         'else:'
%%         '    return x' @};
%% @end group
%% @end example
%% The cell array can be either a row or a column vector.
%% Each of these strings probably should not have any newlines
%% (other than escaped ones e.g., inside strings).  An exception
%% might be Python triple-quoted """ multiline strings """.
%% FIXME: test this.
%% It might be a good idea to avoid blank lines as they can cause
%% problems with some of the IPC mechanisms.
%%
%% Possible input types:
%% @itemize
%% @item sym objects
%% @item strings (char)
%% @item scalar doubles
%% @item structs
%% @end itemize
%% They can also be cell arrays of these items.  Multi-D cell
%% arrays may not work properly.
%%
%% Possible output types:
%% @itemize
%% @item SymPy objects
%% @item int
%% @item float
%% @item string
%% @item unicode strings
%% @item bool
%% @item dict (converted to structs)
%% @item lists/tuples (converted to cell vectors)
%% @end itemize
%% FIXME: add a py_config to change the header?  The python
%% environment is defined in python_header.py.  Changing it is
%% currently harder than it should be.
%%
%% Note: if you don't pass in any syms, this shouldn't need SymPy.
%% But it still imports it in that case.  If  you want to run this
%% w/o having the SymPy package, you'd need to hack a bit.
%%
%% @seealso{evalpy}
%% @end deftypefun

%% Author: Colin B. Macdonald
%% Keywords: python

function varargout = python_cmd(cmd, varargin)

  if (~iscell(cmd))
    if (isempty(cmd))
      cmd = {};
    else
      cmd = {cmd};
    end
  end

  % empty command will cause empty try: except: block
  if isempty(cmd)
    cmd = {'pass'};
  end

  %% IPC interface
  % the ipc mechanism shall put the input variables in the tuple
  % '_ins' and it will return to us whatever we put in the tuple
  % '_outs'.  There is no particular reason this needs to define
  % a function, I just thought it isolates local variables a bit.

  % Careful: fix this constant if you change the code below.
  % Test with "python_cmd('raise')" which should say "line 1".
  LinesBeforeCmdBlock = 3;

  % replace blank lines w/ empty comments (unnec. b/c of try:?)
  %I = cellfun(@isempty, cmd);
  %cmd(I) = repmat({'#'}, 1, nnz(I));

  cmd = indent_lines(cmd, 8);
  cmd = { 'def _fcn(_ins):' ...
          '    _outs = []' ...
          '    try:' ...
          cmd{:} ...
          '    except Exception as e:' ...
          '        ers = type(e).__name__ + ": " + str(e) if str(e) else type(e).__name__' ...
          '        _outs = ("COMMAND_ERROR_PYTHON", ers, sys.exc_info()[-1].tb_lineno)' ...
          '    return _outs' ...
          '' ...
          '_outs = _fcn(_ins)'
        };

  [A, db] = python_ipc_driver('run', cmd, varargin{:});

  if (~iscell(A))
    A={A};
  end

  %% Error reporting
  % ipc drivers are supposed to give back these specially formatting error strings
  if (~isempty(A) && ischar(A{1}) && strcmp(A{1}, 'COMMAND_ERROR_PYTHON'))
    errlineno = A{3} - db.prelines - LinesBeforeCmdBlock;
    error(sprintf('Python exception: %s\n    occurred at line %d of the Python code block', A{2}, errlineno));
  elseif (~isempty(A) && ischar(A{1}) && strcmp(A{1}, 'INTERNAL_PYTHON_ERROR'))
    error(sprintf('Python exception: %s\n    occurred %s', A{3}, A{2}));
  end

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
%! % string with escaped newlines, comes back as escaped newlines
%! x = 'a string\nbroke off\nmy guitar\n';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % string with actual newlines, comes back as actual newlines
%! x = sprintf('a string\nbroke off\nmy guitar\n');
%! y = python_cmd ('return _ins', x);
%! y2 = strrep(y, sprintf('\n'), sprintf('\r\n'));  % windows
%! assert (strcmp(x, y) || strcmp(x, y2))

%!test
%! % cmd string with newlines, works with cell
%! y = python_cmd ('return "string\nbroke",');
%! y2 = sprintf('string\nbroke');
%! y3 = strrep(y2, sprintf('\n'), sprintf('\r\n'));  % windows
%! assert (strcmp(y, y2) || strcmp(y, y3))

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
%! x = 'a\"b\"c';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))
%! x = '\"';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % cmd has double quotes, these must be escaped by user
%! % (of course: she is writing python code)
%! expy = 'a"b"c';
%! y = python_cmd ('return "a\"b\"c",');
%! assert (strcmp(y, expy))

%!test
%! % strings with quotes
%! x = 'a''b';  % this is a single quote
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % strings with quotes
%! x = '\"a''b\"c''\"d';
%! y = python_cmd ('return _ins[0]', x);
%! assert (strcmp(y, x))

%!test
%! % strings with quotes
%! expy = '"a''b"c''"d';
%! y = python_cmd ('s = "\"a''b\"c''\"d"; return s');
%! assert (strcmp(y, expy))

%!test
%! % strings with printf escapes
%! x = '% %% %%% %%%% %s %g %%s';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % cmd with printf escapes
%! x = '% %% %%% %%%% %s %g %%s';
%! y = python_cmd (['return "' x '",']);
%! assert (strcmp(y, x))

%!test
%! % cmd w/ backslash and \n must be escaped by user
%! expy = 'a\b\\c\nd\';
%! y = python_cmd ('return "a\\b\\\\c\\nd\\",');
%! assert (strcmp(y, expy))

%!test
%! % slashes
%! x = '/\\ // \\\\ \\/\\/\\';
%! z = '/\ // \\ \/\/\';
%! y = python_cmd ('return _ins', x);
%! assert (strcmp(y, x))

%!test
%! % slashes
%! z = '/\ // \\ \/\/\';
%! y = python_cmd ('return "/\\ // \\\\ \\/\\/\\"');
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
%! assert (strcmp (s1, s2))

%!test
%! % unicode with \x
%! s1 = '我';
%! cmd = 'return b"\xe6\x88\x91".decode("utf-8")';
%! s2 = python_cmd (cmd);
%! assert (strcmp (s1, s2))

%!test
%! % unicode with \x and some escaped backslashes
%! s1 = '\我\';
%! cmd = 'return b"\\\xe6\x88\x91\\".decode("utf-8")';
%! s2 = python_cmd (cmd);
%! assert (strcmp (s1, s2))

%!xtest
%! % unicode passthru
%! s = '我爱你';
%! s2 = python_cmd ('return _ins', s);
%! assert (strcmp (s, s2))
%! s = '我爱你<>\&//\#%% %\我';
%! s2 = python_cmd ('return _ins', s);
%! assert (strcmp (s, s2))

%!xtest
%! % unicode w/ slashes, escapes
%! s = '我<>\&//\#%% %\我';
%! s2 = python_cmd ('return "我<>\\&//\\#%% %\\我"');
%! assert (strcmp (s, s2))

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

%!test
%! r = python_cmd ('return 6');
%! assert (isequal (r, 6))

%!test
%! r = python_cmd ('return "Hi"');
%! assert (strcmp (r, 'Hi'))

%!test
%! % blank lines, lines with spaces
%! a = python_cmd({ '', '', '     ', 'return 6', '   ', ''});
%! assert (isequal (a, 6))

%!test
%! % blank lines, strange comment lines
%! cmd = {'a = 1', '', '#', '', '#   ', '     #', 'a = a + 2', '  #', 'return a'};
%! a = python_cmd(cmd);
%! assert (isequal (a, 3))

%!test
%! % return empty string (was https://bugs.python.org/issue25270)
%! assert (isempty (python_cmd ('return ""')))

%!test
%! % return nothing (via an empty list)
%! % note distinct from 'return [],'
%! python_cmd('return []')

%!test
%! % return nothing (because no return command)
%! python_cmd('dummy = 1')

%!test
%! % return nothing (because no command)
%! python_cmd('')

%!test
%! % return nothing (because no command)
%! python_cmd({})

%!xtest error <AttributeError>
%! % Fails using pytave IPC due to #457 (Pytave returning python exceptions)
%! % python exception while passing variables to python
%! % FIXME: this is a very specialized test, relies on internal octsympy
%! % implementation details, and may need to be adjusted for changes.
%! b = sym([], 'S.make_an_attribute_err_exception', [1 1], 'Test', 'Test', 'Test');
%! c = b + 1;
%!test
%! % ...and after the above test, the pipe should still work
%! a = python_cmd('return _ins[0]*2', 3);
%! assert (isequal (a, 6))

%!xtest error <octoutput does not know how to export type>
%! % This command does not fail with PyTave and '@pyobject'
%! python_cmd({'return type(int)'});
%!test
%! % ...and after the above test, the pipe should still work
%! a = python_cmd('return _ins[0]*2', 3);
%! assert (isequal (a, 6))

%!test
%! % complex input
%! [A, B] = python_cmd ('z = 2*_ins[0]; return (z.real,z.imag)', 3+4i);
%! assert (A, 6)
%! assert (B, 8)

%!test
%! % complex output
%! z = python_cmd ('return 3+2j');
%! assert (z, 3+2i)
