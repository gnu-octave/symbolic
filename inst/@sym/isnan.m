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
%% @deftypefn {Function File}  {@var{r} =} isnan (@var{x})
%% Return true if a symbolic expression is Not-a-Number.
%%
%% @seealso{isinf, double}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function r = isnan(x)

  % todo: neat idea but fails for matrices
  %r = isnan (double (x, false));

  if isscalar(x)

    cmd = 'return (_ins[0] == sp.nan,)';

    r = python_cmd (cmd, x);

    if (~ islogical(r))
      error('nonboolean return from python');
    end

  else  % array
    r = logical(zeros(size(x)));
    for j = 1:numel(x)
      % Bug #17
      idx.type = '()';
      idx.subs = {j};
      r(j) = isnan(subsref(x, idx));
    end
  end
