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

%% Usage: [X] = sym (Y)
%% Define symbols and numbers as symbolic expressions.
%% Y can be an integer, a string or one of several special
%% double values.
%%
%% Examples:
%%
%% x = sym ('x')
%% y = sym ('2')
%% y = sym (3)
%% y = sym (inf)
%% y = sym (pi)

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function s = sym(x, varargin)
%SYM  Symbolic class implemented with sympy
%

  if (nargin == 0)
    s = sym(0);
    return
  end

  if (strcmp (class (x), 'sym'))
    s = x;
    return
  end

  if (nargin == 2)
    s.text = x;
    s.pickle = varargin{1};
    s = class(s, 'sym');
    return
  end

  if (isa (x, 'double'))
    % TODO: maybe cleaner to generate a string and then call the
    % constructor again....
    if (x == pi)
      cmd = 'z = sp.pi\n';
    elseif (isinf(x)) && (x > 0)
      cmd = 'z = sp.oo\n';
    elseif (isinf(x)) && (x < 0)
      cmd = 'z = -sp.oo\n';
    elseif (mod(x,1) == 0)
      % is integer
      cmd = sprintf('z = sp.Rational("%d")\n', x);
    else
      error('use quoted input for fractions');
      % TODO: matlab SMT allows 1/3 and other "small" fractions, but
      % I don't trust this behaviour much.
    end
  elseif (isa (x, 'char'))
    if (strcmp(x, 'pi'))
      cmd = 'z = sp.pi\n';
    elseif (strcmp(x, 'inf')) || (strcmp(x, '+inf'))
      cmd = 'z = sp.oo\n';
    elseif (strcmp(x, '-inf'))
      cmd = 'z = -sp.oo\n';
    else
      if (~isempty((strfind(x, '.'))))
        warning('possible unintended decimal point in constructor string');
      end
      cmd = sprintf('z = sp.S("%s")\n', x);
      %xd = str2double(x);
      %if (isnan (xd))
      %  cmd = sprintf('z = sp.Symbol("%s")\n', x);
      %else
      %  cmd = sprintf('z = sp.Rational("%d")\n', xd);
      %end
    end
  else
    error('conversion from that type to symbolic not (yet) supported');
  end

  fullcmd = [ 'def fcn(ins):\n'  ...
              '    ' cmd  ...
              '    return (z,)\n' ];
  A = python_sympy_cmd_raw(fullcmd);
  s.text = A{1};
  s.pickle = A{2};
  s = class(s, 'sym');

