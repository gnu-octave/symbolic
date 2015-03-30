%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{r} =} octsympy_doctests ()
%% Run doctests for OctSymPy, and return true if passing.
%%
%% You will need to have @code{doctest-for-matlab} installed from
%% @url{https://github.com/catch22/doctest-for-matlab}.  It must
%% already be in your path.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: tests

function r = octsympy_doctests()

  syms x
  sympref snippet off
  % FIXME: probably others to do not have it installed here!
  % addpath('../doctest-for-matlab')

  [n, fail, extract_fail] = doctest('logical', 'symfun', 'sym', ...
    'assumptions', 'catalan', 'eulergamma', 'fibonacci', 'python_cmd', ...
    'sympref', 'vpa', 'bernoulli', 'digits', 'evalpy', 'findsymbols', ...
    'poly2sym', 'syms', 'vpasolve');

  r = fail;

end


% just to keep octsympy_tests quiet
%!assert(true)
