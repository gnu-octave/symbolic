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
%% @deftypefn  {Function File}  {@var{z} =} mpower (@var{x}, @var{y})
%% Symbolic expression matrix exponentiation (^).
%%
%% We implement scalar ^ scalar and matrix ^ scalar.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mpower(x, y)

  cmd = 'return _ins[0]**_ins[1],';

  if isscalar(x) && isscalar(y)
    z = python_cmd (cmd, sym(x), sym(y));

  elseif isscalar(x) && ~isscalar(y)
    error('scalar^array not implemented');

  elseif ~isscalar(x) && isscalar(y)
    % fixme: sympy can do int and rat, then MatPow, check MST
    z = python_cmd (cmd, sym(x), sym(y));

  else  % two array's case
    error('array^array not implemented');
  end


%!test
%! syms x
%! assert(isequal(x^(sym(4)/5), x.^(sym(4)/5)))
