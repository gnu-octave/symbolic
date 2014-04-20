function varargout = python_cmd(cmd, varargin)
%PYTHON_CMD  Run Python command and return objects
%   Run a Python command which takes some Octave objects as
%   inputs and returns Octave objects as
%   outputs.
%
%      [a,b,c,...] = python_cmd (cmd, x, y, z, ...)
%
%   where x,y,z can be sym objects, strings (char), or scalar doubles.
%   The can also be cell arrays of these items.  Multi-D cell arrays
%   may not work properly.  Ouputs
%
%   Example:
%      cmd = '(x,y) = _ins; return (x+y,x-y)';
%      [a,b] = python_cmd (cmd, x, y);
%      % now a == x + y and b = x - y
%
%   Here 'cmd' is a string consisting of python code.  The inputs will
%   be in a list called '_ins'.  The command should end by outputing a
%   tuple of return arguments.
%
%   If you have just one return value, you probably want to append
%   an extra comma as in this example:
%      cmd = '(x,y) = _ins; return (x+y,)';
%   (Python gurus will know why).
%
%%
%% You can also append to the (initially empty) Python list
%% '_outs' which will be returned if you don't return anything.
%%
%% The string can have newlines for longer commands but be careful
%% with whitespace: its pythpn!
%%  cmd = [ '(x,) = _ins\n'  ...
%%          'if x.is_Matrix:\n'  ...
%%          '    return ( x.T ,)\n' ...
%%          'else:\n' ...
%%          '    return ( x ,)\n' ];
%%
%%
%   FIXME: add a py_config to change the header?  The python environment
%   defined in python_header.py.  Changing it is currently harder than it
%   should be.
%
% Note: if you don't pass in any sym's, this won't (shouldn't
% anyway) use SymPy.  But it still imports it in that case.  If
% you want to run this w/o having the SymPy package, you'd need
%  to hack a bit.


  newl = sprintf('\n');
  cmd = sprintf(cmd);   % ensure we printf the cmd to get newlines
  cmd = strtrim(cmd);   % trims whitespace and newlines from beginning and end
  cmd = strrep(cmd, newl, [newl '    ']);  % indent each line by 4

  cmd = sprintf( [ 'def _fcn(_ins):\n' ...
                   '    _outs = []\n' ...
                   '    %s\n' ...
                   '    return _outs\n' ...
                   '\n' ...
                   '_outs = _fcn(_ins)\n\n' ], cmd);

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
