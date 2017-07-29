% Copyright (C) 2014-2017 Colin B. Macdonald
%
% This file is part of OctSymPy.
%
% OctSymPy is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published
% by the Free Software Foundation; either version 3 of the License,
% or (at your option) any later version.
%
% This software is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
% the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public
% License along with this software; see the file COPYING.
% If not, see <http://www.gnu.org/licenses/>.

addpath(pwd)
base = 'tests_matlab';
files = dir(base);
cd(base);

% usually I'd just use cputime(), but some of our IPC mechanisms are
% light on CPU and heavy on IO.
totaltime = clock();
totalcputime = cputime();
num_tests = 0;
% do tests in random order:
%rng('shuffle')
%for i=randperm(length(files))
for i=1:length(files)
  mfile = files(i).name;
  % detect tests b/c directory contains other stuff (e.g., surdirs and
  % helper files)
  if ( (~files(i).isdir) && strncmp(mfile, 'test', 4) && mfile(end) ~= '~')
    testtime = clock();
    str = mfile(1:end-2);
    num_tests = num_tests + 1;
    fprintf(['>>> Running test(s) in: ' mfile '  ']);  % no newline
    eval(str)
    testtime = etime(clock(), testtime);
  end
end

totaltime = etime(clock(),totaltime);
totalcputime = cputime() - totalcputime;
fprintf('\n***** Ran tests from %d files, %g seconds (%gs CPU) *****\n', ...
        num_tests, totaltime, totalcputime);
cd('..')
