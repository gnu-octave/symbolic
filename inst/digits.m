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
%% @deftypefn  {Function File} {@var{n} =} digits ()
%% @deftypefnx {Function File} {} digits (@var{n})
%% @deftypefnx {Function File} {@var{oldn} =} digits (@var{n})
%% Get/set number of digits used in variable precision arith.
%%
%% @seealso{sym, vpa, vpasolve}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function m = digits(n)

  if (nargin == 0) || (nargout == 1)
    m = sympref('digits');
  end
  if (nargin == 1)
    sympref('digits', n);
  end
end


%!test
%! orig = digits(32);  % to reset later
%! m = digits(64);
%! p = vpa(sym(pi));
%! assert (abs (double (sin(p))) < 1e-64)
%! n = digits(m);
%! assert (n == 64)
%! p = vpa(sym(pi));
%! assert (abs (double (sin(p))) < 1e-32)
%! assert (abs (double (sin(p))) > 1e-40)
%! digits(orig)

