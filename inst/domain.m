%% Copyright (C) 2017 Lagu
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
%% @documentencoding UTF-8
%% @defmethod domain (@var{x})
%% Return the domain @var{x}.
%%
%% List of supported domains (from SymPy 1.0.1):
%%   EmptySet
%%   Integers
%%   Naturals
%%   Naturals0 (Naturals with 0)
%%   Reals
%%   Complexes
%%   UniversalSet
%%
%% Example:
%% @example
%% @group
%% domain ('Reals')
%%   @result{} ans = (sym) ℝ
%% @end group
%% @end example
%%
%% @example
%% @group
%% domain ('Complexes')
%%   @result{} ans = (sym) ℂ
%% @end group
%% @end example
%%
%% @end defmethod


function y = domain(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = python_cmd (strrep ('return S.{domain}', '{domain}', x));
end
