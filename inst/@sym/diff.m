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
%% @deftypefn {Function File} {@var{g} =} diff (@var{f})
%% @deftypefnx {Function File} {@var{g} =} diff (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} diff (@var{f}, ...)
%% Symbolic differentiation.
%%
%% Examples:
%% @example
%% syms x
%% f = sqrt(sin(x/2))
%% diff(f)
%% diff(f,x)
%% diff(f,x,x,x)
%% @end example
%%
%% Partial differentiation:
%% @example
%% syms x y
%% f = cos(2*x + 3*y)
%% diff(f,x,y,x);
%% diff(f,x,2,y,3);
%% @end example
%%
%% Other examples:
%% @example
%% diff(sym(1))
%% @end example
%%
%% @seealso{int}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, differentiation

function z = diff(f, varargin)

  % simpler version, but gives error on differentiating a constant
  %cmd = 'return sp.diff(*_ins),';

  cmd = [ '# special case for one-arg constant\n'             ...
          'if (len(_ins)==1 and _ins[0].is_constant()):\n'    ...
          '    return (sp.numbers.Zero(),)\n'                 ...
          'd = sp.diff(*_ins)\n'                              ...
          'return (d,)' ];

  varargin = sym(varargin);
  z = python_cmd (cmd, sym(f), varargin{:});
