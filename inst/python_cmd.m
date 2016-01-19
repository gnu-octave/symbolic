%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {[@var{a}, @var{b}, @dots{}] =} python_cmd (@var{cmd}, @var{x}, @var{y}, @dots{})
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
%% >> x = 10; y = 2;
%% >> cmd = '(x,y) = _ins; return (x+y,x-y)';
%% >> [a, b] = python_cmd (cmd, x, y)
%%    @result{} a =  12
%%    @result{} b =  8
%% @end group
%% @end example
%%
%% The inputs will be in a list called '_ins'.  The command should
%% end by outputing a tuple of return arguments.
%% If you have just one return value, you probably want to append
%% an extra comma.  Either of these approaches will work:
%% @example
%% @group
%% >> cmd = '(x,y) = _ins; return (x+y,)';
%% >> a = python_cmd (cmd, x, y)
%%    @result{} a =  12
%% >> cmd = '(x,y) = _ins; return x+y,';
%% >> a = python_cmd (cmd, x, y)
%%    @result{} a =  12
%% @end group
%% @end example
%% (Python gurus will know why).
%%
%% Instead of @code{return}, you can append to the Python list
%% @code{_outs}:
%% @example
%% @group
%% >> cmd = '(x,y) = _ins; _outs.append(x**y)';
%% >> a = python_cmd (cmd, x, y)
%%    @result{} a =  100
%% @end group
%% @end example
%%
%% You can also pass a cell-array of lines of code.  But be careful
%% with whitespace: its Python!
%% @example
%% @group
%% >> cmd = @{ '(x,) = _ins'
%% ..         'if x.is_Matrix:'
%% ..         '    return (x.T,)'
%% ..         'else:'
%% ..         '    return (x,)' @};
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
%% @end itemize
%% They can also be cell arrays of these items.  Multi-D cell
%% arrays may not work properly.
%%
%% Possible output types:
%% @itemize
%% @item SymPy objects (Matrix and Expr at least)
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
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: python

function varargout = python_cmd(cmd, varargin)

  if (~iscell(cmd))
    cmd = {cmd};
  end

  %% IPC interface
  % the ipc mechanism shall put the input variables in the tuple
  % '_ins' and it will return to us whatever we put in the tuple
  % '_outs'.  There is no particular reason this needs to define
  % a function, I just thought it isolates local variables a bit.

  %% Handle errors
  % be careful, the number of line of cmd most be fixed if you
  % change cmd, the number line is from here: 
  % sys.exc_info()[-1].tb_lineno - 4
  % to know the rest write python_cmd('raise'), it should return
  % "some error" (line 1). If not fix it.

  cmd = indent_lines(cmd, 8);
  cmd = { 'def _fcn(_ins):' ...
          '    _outs = []' ...
          '    try:' ...
          cmd{:} ...
          '        return _outs' ...
          '    except Exception as e:' ...
          '        exc_type, exc_obj, tb = sys.exc_info()' ...
          '        ers = type(e).__name__ + ": " + str(e) if str(e) else type(e).__name__' ...
          '        return ("COMMAND_ERROR_PYTHON", ers + " (line " + str(sys.exc_info()[-1].tb_lineno - 4) + ")")' ...
          '_outs = _fcn(_ins)'
         };

  [A, db] = python_ipc_driver('run', cmd, varargin{:});

  if (strcmp(A{1}, 'COMMAND_ERROR_PYTHON'))
    error(A{2});
  end

  if (~iscell(A))
    disp(A)
    % Python state undefined, so reset it (overkill for nostateful ipc)
    sympref reset
    error('OctSymPy:python_cmd:unexpected', 'python_cmd: unexpected return')
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
%! % string with newlines
%! % FIXME: escaped in input should still be escaped in output
%! x = 'a string\nbroke off\nmy guitar\n';
%! x2 = sprintf(x);
%! y = python_cmd ('return _ins', x);
%! x3 = strrep(x2, sprintf('\n'), sprintf('\r\n'));  % windows
%! assert (strcmp(y, x2) || strcmp(y, x3))

%!test
%! % bug: cmd string with newlines, works with cell
%! % FIXME: no addition escaping for this one
%! y = python_cmd ('return "string\nbroke",');
%! y2 = sprintf('string\nbroke');
%! y3 = strrep(y2, sprintf('\n'), sprintf('\r\n'));  % windows
%! assert (strcmp(y, y2) || strcmp(y, y3))

%%!test
%%! % FIXME: newlines: should be escaped for import?
%%! x = 'a string\nbroke off\nmy guitar\n';
%%! x2 = sprintf(x);
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
%! % slashes: FIXME: auto escape backslashes
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
%! assert (strcmp (s1, s2))

%%!test
%%! % unicode passthru: FIXME: how to get unicode back to Python?
%%! s1 = '我爱你'
%%! cmd = 'return (_ins[0],)';
%%! s2 = python_cmd (cmd, s1)
%%! assert (strcmp (s1, s2))

%%!test
%%! % unicode w/ slashes, escapes, etc  FIXME
%%! s1 = '我爱你<>\\&//\\#%% %\\我'
%%! s3 = '我爱你<>\&//\#%% %\我'
%%! cmd = 'return u"\u6211\u7231\u4f60",';
%%! s2 = python_cmd (cmd)
%%! assert (strcmp (s2, s3))

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
