%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod  @@sym gammaln (@var{x})
%% @defmethodx @@sym lgamma (@var{x})
%% Symbolic logarithm of the gamma function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = gammaln(x)
%%   @result{} y = (sym) loggamma(x)
%% y = lgamma(x)
%%   @result{} y = (sym) loggamma(x)
%% @end group
%% @end example
%%
%% @seealso{gammaln, @@sym/gamma, @@sym/psi}
%% @end defmethod

function y = lgamma(x)
  y = gammaln(x);
end


%!test
%! % tested by gammaln
%! assert (isequal (lgamma (sym ('x')), gammaln (sym ('x'))))
