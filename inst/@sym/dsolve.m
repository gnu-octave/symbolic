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
%% @deftypefn {Function File} {@var{g} =} dsolve (@var{de}, @var{y}, @var{ic})
%% Solve ODEs symbolically.
%%
%% Note @var{y} must be a symfun.
%% FIXME: not sure sympy is really so strict, currently in sym.
%% FIXME: deal with ICs?
%%
%% @seealso{int}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function soln = dsolve(de, y, ic)

  % Usually we cast to sym in the _cmd call, but want to be
  % careful here b/c of symfuns
  if ~ (isa(de, 'sym') && isa(y, 'sym')
    error('inputs must be sym or symfun')
  end

  if (isscalar(de))
    cmd = [ '(_de,_y) = _ins\n'  ...
            'g = sp.dsolve(_de,_y)\n'  ...
            'return (g,)' ];

    soln = python_cmd (cmd, de, y);

    if (nargin == 3)
      warning('todo: ICs not supported yet')
      stop
    end


  else
    error('TODO system case')
  end

