%% Copyright (C) 2016 Lagu
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
%% @defmethod @@sym dawson (@var{x})
%% Symbolic Dawson (scaled imaginary error) function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% dawson (x)
%%   @result{} ans = (sym)
%%             2
%%           -x
%%       √π⋅ℯ   ⋅erfi(x)
%%       ───────────────
%%              2
%% @end group
%% @end example
%% @seealso{dawson, @@sym/erfc, @@sym/erf, @@sym/erfcx, @@sym/erfi, @@sym/erfinv, @@sym/erfcinv}
%% @end defmethod


function y = dawson(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: exp(-a**2)*erfi(a)*(sqrt(S(pi))/2)', x);
end


%!test
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! % dawson missing on Matlab, Issue #742
%! A = dawson([1 2]);
%! B = double(dawson(sym([1 2])));
%! assert(A, B, -eps)
%! end
