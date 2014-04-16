%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -- Loadable Function: X = sym (Y)
%%     Define symbols and numbers as symbolic expressions.
%%
%%     Y can be an integer, a string or one of several special
%%     double values.  It can also be a double matrix or a cell array.
%%
%%     Examples:
%%
%%     x = sym ('x')
%%     y = sym ('2')
%%     y = sym (3)
%%     y = sym (inf)
%%     y = sym (pi)
%%     y = sym ( sym (pi))   % idempotent

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function s = sym(x, varargin)
%SYM  Symbolic class implemented with sympy
%

  if (nargin == 0)
    s = sym(0);
    return
  end


  % todo: may not want to expose this in constructor: private usage
  if (nargin == 2)
    s.text = x;
    s.pickle = varargin{1};
    s.extra = [];
    s = class(s, 'sym');
    return
  end


  % not a subclass, exactly a sym, not symfun
  %if (strcmp (class (x), 'sym'))
  if (isa (x, 'sym'))
    s = x;
    return

  elseif (iscell (x))
    s = cell_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isscalar (x) )
    s = double_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isreal (x) )
    s = sym(real(x)) + sym('I')*sym(imag(x));
    return

  elseif (isa (x, 'double'))
    if (x == pi)
      s = sym('pi');
    elseif (isinf(x)) && (x > 0)
      s = sym('inf');
    elseif (isinf(x)) && (x < 0)
      s = sym('-inf');
    elseif (isnan(x))
      s = sym('nan');
    elseif (mod(x,1) == 0)   % is integer
      s = sym(sprintf('%d', x));
    else
      % Allow 1/3 and other "small" fractions.
      % FIXME: good if this waring were configurable, personally I like
      % it to at least warn so I can catch bugs.
      % Matlab SMT also does this (w/o warning).
      % I don't trust this behaviour much.
      warning('Using rats() for rational approx, did you really mean to pass a noninteger?');
      s = sym(rats(x));
    end
    return


  elseif (isa (x, 'char'))
    if (strfind(x, '('))
      % symfun spagetti code :-(
      disp('hack: rhs is hopefully for a symfun');
      s = sym(1);
      s.text = {'UGLY HACK', x};
      %s = x;  % fails to call subsasgn
      return
    end
    if (strcmp(x, 'pi'))
      cmd = 'z = sp.pi\n';
    elseif (strcmpi(x, 'inf')) || (strcmpi(x, '+inf'))
      cmd = 'z = sp.oo\n';
    elseif (strcmpi(x, '-inf'))
      cmd = 'z = -sp.oo\n';
    elseif (strcmpi(x, 'nan'))
      cmd = 'z = sp.nan\n';
    elseif (strcmpi(x, 'i'))
      cmd = 'z = sp.I\n';
    else
      if (~isempty((strfind(x, '.'))))
        warning('possibly unintended decimal point in constructor string');
      end
      cmd = sprintf('z = sp.S("%s")\n', x);
    end
  else
    x
    class(x)
    error('conversion from that type to symbolic not (yet) supported');
  end

  fullcmd = [ 'def fcn(ins):\n'  ...
              '    ' cmd  ...
              '    return (z,)\n' ];
  s = python_sympy_cmd(fullcmd);

