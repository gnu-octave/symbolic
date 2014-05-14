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
%% @deftypefnx {Function File} {} syms
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
%% The last argument can provide an assumption (type or
%% restriction) on the variable (@xref{sym}, for details.)
%% @example
%% syms x y z positive
%% @end example
%%
%% Called without arguments, @code{syms} displays a list of
%% all symbolic functions defined in the current workspace.
%%
%% Careful: this code runs @code{evalin()}: you should not
%% use it (programmatically) on strings you don't trust.
%%
%% @seealso{sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function syms(varargin)

  %% No inputs
  %output names of symbolic vars
  if (nargin == 0)
    S = evalin('caller', 'whos');
    for i=1:numel(S)
      %S(i)
      if strcmp(S(i).class, 'sym')
        disp(S(i).name)
      elseif strcmp(S(i).class, 'symfun')
        % FIXME improve display of symfun
        disp([S(i).name ' (symfun)'])
      end
    end
    return
  end

  asm = varargin{end};
  if ( strcmp(asm, 'real') || strcmp(asm, 'positive') || strcmp(asm, 'integer') || ...
       strcmp(asm, 'even') || strcmp(asm, 'odd') || strcmp(asm, 'rational') || ...
       strcmp(asm, 'clear') )
    asm = [', ''' asm ''''];
    last = nargin-1;
  else
    asm = '';
    last = nargin;
  end
  for i = 1:last
    cmd = sprintf('%s = sym(''%s''%s);', varargin{i}, varargin{i}, asm);
    evalin('caller', cmd)
  end

