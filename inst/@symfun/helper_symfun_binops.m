%% Copyright (C) 2014, 2019 Colin B. Macdonald
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

function [vars,s1,s2] = helper_symfun_binops(f, g)

  if (isa(f,'symfun')) && (isa(g, 'symfun'))
    %disp('debug: symfun <op> symfun')
    if ~isequal(f.vars, g.vars)
      error('arithmetric operators on symfuns must have same vars')
    end
    vars = f.vars;
    s1 = formula (f);
    s2 = formula (g);
  elseif (isa(f,'symfun'))
    %disp('debug: symfun <op> sym')
    vars = f.vars;
    s1 = formula (f);
    s2 = g;
  elseif (isa(g, 'symfun'))
    %disp('debug: sym <op> symfun')
    vars = g.vars;
    s1 = f;
    s2 = formula (g);
  else
    error('Tertium Non Datur')
  end

