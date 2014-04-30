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
%% @deftypefn  {Function File} {@var{n} =} numel (@var{f})
%% Number of elements in symbolic array of symfuns.
%%
%% FIXME: Why do I need this in the subclass symfun?  why is it called so much?
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function n = numel(f)

  %disp('symfun numel call') %, hardcoded to 1')
  %n = 1;

  n = numel(f.sym);
