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
%% @deftypefn  {Function File} {@var{g} =} taylor (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} taylor (@var{f}, @var{x}, @var{a}, @var{n})
%% Symbolic Taylor series.
%%
%% FIXME: look at Matlab SMT interface
%%
%% @seealso{diff}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, differentiation

function s = taylor(f,x,a,varargin)

  %if (nargin == 3)
  %  n =
  n = 8;
  warning('todo');

  cmd = [ '(f,x,a,n) = _ins\n'  ...
          's = f.series(x,a,n).removeO()\n'  ...
          'return (s,)' ];
  s = python_cmd(cmd, sym(f), sym(x), sym(a), n);

