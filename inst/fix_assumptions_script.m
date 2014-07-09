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
%% @deftypefn  {Command} {} fix_assumptions_script
%% Traverse the current workspace replacing symbolic varibles.
%%
%% Before calling this, you must define a sym called
%% @code{hack__newx__}.  Any sym variables with the same names as
%% @code{hack__newx__} will be replaced with @code{hack__newx__}.
%%
%% This is not a function, its a script: it roots around in your
%% workspace (and inside your structs and cell-arrays,
%% recursively).  This is probably as dangerous as it sounds, but I
%% have not thought of an easier way to build Matlab-like behaviour
%% on top of our assumptions system.
%%
%% @seealso{assume, assumeAlso, assumptions, sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

warning('Deprecated (FIXME: remove later)');

if ~(exist ('hack__newx__', 'var'))
  error('you must define "hack__newx__" first, see help')
end
if ~(exist ('hack__xstr__', 'var'))
  hack__xstr__ = strtrim(disp(hack__newx__));
end

hack__S__ = whos();

for hack__i__ = 1:numel(hack__S__)
  if isempty(regexp(hack__S__(hack__i__).name, '^hack__.*__'))
    hack__obj__ = eval(hack__S__(hack__i__).name);
    [hack__newobj__, hack__flag__] = ...
        symreplace(hack__obj__, hack__xstr__, hack__newx__);
    if (hack__flag__)
      eval([hack__S__(hack__i__).name '= hack__newobj__;']);
    end
  end
end

% clean up after ourselves
clear hack__S__ hack__i__ hack__flag__ hack__obj__ hack__newobj__
clear hack__newx__ hack__xstr__
