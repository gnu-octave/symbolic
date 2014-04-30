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
%% @deftypefn  {Function File} {} syms @var{x}
%% @deftypefnx {Function File} {} syms @var{f(x)}
%% Create symbolic variables and symbolic functions.
%%
%% This is a convenience function.  For example:
%% @example
%% syms x y z
%% @end example
%% instead of:
%% @example
%% x = sym('x');
%% y = sym('y');
%% z = sym('z');
%% @end example
%%
%% Careful: this code runs evalin(): you should not use it
%% (programmatically) on strings you don't trust.
%%
%% @seealso{sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function syms(varargin)

  % todo, support symfuns via syms y(x)
  for i = 1:nargin
    cmd = sprintf('%s = sym(''%s'');', varargin{i}, varargin{i});
    %disp(['evaluating command: ' cmd])
    evalin('caller', cmd)
  end

