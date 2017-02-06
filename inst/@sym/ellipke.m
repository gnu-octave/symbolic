%% Copyright (C) 2016-2017 Lagu
%% Copyright (C) 2017 Colin B. Macdonald
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
%% @defmethod @@sym [@var{K}, @var{E}] = ellipke (@var{m})
%% Complete elliptic integrals of the first and second kinds.
%%
%% Example:
%% @example
%% @group
%% syms m
%% [K, E] = ellipke (m)
%%   @result{} K = (sym) K(m)
%%   @result{} E = (sym) E(m)
%% @end group
%% @end example
%%
%% @seealso{ellipke, @@sym/ellipticK, @@sym/ellipticE}
%% @end defmethod


function varargout = ellipke(m)

  if (nargin ~= 1 || nargout > 2)
    print_usage ();
  end

  if (nargout == 0 || nargout == 1)
    varargout = {ellipticK(m)};
  else
    varargout = {ellipticK(m) ellipticE(m)};
  end

end


%!error <Invalid> ellipke (sym(1), 2)

%!test
%! for i = 2:10
%!   [K E] = ellipke (sym (1)/i);
%!   [k e] = ellipke (1/i);
%!   assert (double ([K E]), [k e], 2*eps)
%! end
