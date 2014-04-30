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
%% @deftypefn  {Function File} {@var{y} =} symfun (@var{x})
%% Define a symbolic function (not usually called directly).
%%
%% Example: note the symfun() constructor is not called directly.
%% @example
%% syms x
%% y(x) = x^2
%% y(2)
%% @end example
%%
%% Unknown function examples:
%% @example:
%% syms x y     % FIXME: this unnecessary in the Matlab SMT?
%% syms f(x) g(x,y)
%% @end example
%%
%% Equivalently:
%% @example
%% x = sym('x')
%% y = sym('y')
%% f(x) = sym('f(x)')
%% g(x,y) = sym('g(x,y)')
%% @end example
%%
%% @seealso{sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function f = symfun(expr, vars, varargin)

  if (nargin == 0)
    % octave docs say need a no argument default for loading from files
    expr = sym(0)
    vars = sym('x')
  end


  if (isa( expr, 'sym'))
    f.vars = vars;
    f = class(f, 'symfun', expr);
    superiorto ('sym');
    return
  end

