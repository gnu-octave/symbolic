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
%% @deftypefn  {Function File}  {[@var{a}, @var{b}, ...] =} python_cmd (@var{cmd}, @var{x}, @var{y}, ...)
%% Run some Python command on some objects and return other objects.
%%
%% Here @var{cmd} is a string of Python code.
%% Inputs @var{x}@, @var{y}@, ... can be a variety of objects
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


  %% a big of preprocessing
  % the user might or might not have escaped newlines.  We want to
  % reliably intend this code to put it inside a Python function.
  newl = sprintf('\n');
  cmd = strrep(cmd, '\n', newl);
  cmd = strtrim(cmd);  % I think this is not important
  cmd = strrep(cmd, newl, [newl '    ']);  % indent each line by 4

  cmd = sprintf( [ 'def _fcn(_ins):\n' ...
                   '    _outs = []\n' ...
                   '    %s\n' ...
                   '    return _outs\n' ...
                   '\n' ...
                   '_outs = _fcn(_ins)\n\n' ], cmd);

  %fprintf('\n*** <CODE> ***\n')
  %disp(cmd)
  %fprintf('\n*** </CODE> ***\n\n')

  A = python_sympy_cmd_raw('run', cmd, varargin{:});

  % FIXME: for legacy reasons, there were two strings per output,
  % clean this up sometime.
  M = length(A)/2;
  assert(rem(M,1) == 0)
  varargout = cell(1,M);
  for i=1:M
    dontcare = A{2*i-1};
    estr = A{2*i};
    eval(estr)   % creates a variable called tmp, see *ipc* fcns
    varargout{i} = tmp;
  end

  if nargout ~= M
    warning('number of outputs don''t match, was this intentional?')
  end
end


%% general test
%!test
%! x = 10; y = 6;
%! cmd = '(x,y) = _ins; return (x+y,x-y)';
%! [a,b] = python_cmd (cmd, x, y);
%! assert (a == x + y && b == x - y)

%% bool
%!test
%! assert (python_cmd ('return True,'))
%! assert (~python_cmd ('return False,'))

%% float
%!test
%! assert (python_cmd ('return 1.0/3,'), 1/3, 1e-15)

%% int
%!test
%! assert (python_cmd ('return 123456,'), 123456)

%% string
%!test
%! x = 'octave';
%! cmd = 's = _ins[0]; return s.capitalize(),';
%! y = python_cmd (cmd, x);
%! assert (strcmp(y, 'Octave'))

%% unicode
%!test
%! s1 = '我爱你';
%! s2 = python_cmd ('return u"\\u6211\\u7231\\u4f60",');
%! assert (strcmp (s1,s2))

%% list, tuple
%!assert (python_cmd ('return [1,2,3],'), {1, 2, 3})
%!assert (python_cmd ('return (4,5),'), {4, 5})
%!assert (python_cmd ('return (6,),'), {6,})
%!assert (python_cmd ('return [],'), {})

%% dict
%!test
%! cmd = 'd = dict(); d["a"] = 6; d["b"] = 10; return d,';
%! d = python_cmd (cmd);
%! assert (d.a == 6 && d.b == 10)
