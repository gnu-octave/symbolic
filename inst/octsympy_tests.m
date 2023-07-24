%% Copyright (C) 2014, 2016-2017, 2019, 2022-2023 Colin B. Macdonald
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
%% @defun octsympy_tests ()
%% Run the test suite, log results, and return true if any fail.
%%
%% On recent Octave, this is a thin layer around the built-in Octave
%% command @code{__run_test_suite__ (@{'.'@}, @{@})}.
%%
%% Testing should work once the package is installed, which is otherwise
%% harder to test (need to know the installation directory).
%%
%% TODO: eventually we should drop this file altogether, and use
%% @code{pkg test symbolic} instead, see
%% @url{https://github.com/gnu-octave/symbolic/issues/1142}
%% and @url{https://savannah.gnu.org/bugs/?62681}.
%%
%% @seealso{test, runtests, doctest}
%% @end defun

function anyfail = octsympy_tests ()
  if (compare_versions (OCTAVE_VERSION (), '4.4.0', '>='))
    pkgdir = fileparts (mfilename ('fullpath'))
    % Maybe later: https://savannah.gnu.org/bugs/?55841
    %if (strcmp (fullfile (pkgdir), fullfile (pwd)))
    %  % be quieter if pkgdir is the current dir
    %  pkgdir = '.';
    %end
    [pass, fail] = __run_test_suite__ ({pkgdir}, {});
    anyfail = fail > 0;
    return
  end

  error ('older Octave not supported')
end


% muhaha, no one is watching the watchers
%!assert(true)
