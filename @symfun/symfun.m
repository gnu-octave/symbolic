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

%% Usage: y = symfun (Y)
%% Define a symbolic function in terms of a symbolic expression Y, but
%% usually you need not call this directly.
%%
%% Examples:
%%
%% x = sym ('x')
%% y(x) = x^2
%% f(x) = sym(y(x))  % todo check this matches MST notation

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function f = symfun(expr, vars, varargin)
%SYMFUN  Symbolic function class implemented with sympy
%

  if (nargin == 0)
    % octave docs say need a no argument default for loading from files
    expr = sym(0)
    vars = sym('x')
  end


  if ~(isa( expr, 'sym'))
    error('hmmmm?')
    return
  end

  %fullcmd = [ 'def fcn(ins):\n'  ...
  %            '    ' cmd  ...
  %            '    return (z,)\n' ];
  %A = python_sympy_cmd_raw(fullcmd);
  %s.text = A{1};
  %s.pickle = A{2};
  %f.text = ['symfun: ' expr.text];  % todo
  %f.pickle = expr.pickle;
  %f.expr = expr;
  f.vars = vars;
  
  f = class(f, 'symfun', expr);

