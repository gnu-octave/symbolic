%% Copyright (C) 2016-2017 Lagu
%% Copyright (C) 2017, 2019 Colin B. Macdonald
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
%% @defmethod @@sym ellipticCK (@var{m})
%% Complementary complete elliptic integral of the first kind.
%%
%% The complete elliptic integral (of the first kind) with the
%% complementary parameter @code{1 - @var{m}} is given by:
%% @example
%% @group
%% syms m
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% ellipticCK (m)
%%   @result{} ans = (sym) K(1 - m)
%% @end group
%% @end example
%%
%% Example:
%% @example
%% @group
%% ellipticCK (sym (1)/4)
%%   @result{} ans = (sym) K(3/4)
%% vpa (ans)
%%   @result{} (sym) 2.1565156474996432354386749988003
%% @end group
%% @end example
%%
%% There are other conventions for the inputs of elliptic integrals,
%% @pxref{@@sym/ellipticF}.
%%
%% @seealso{@@sym/ellipticK}
%% @end defmethod


function y = ellipticCK (m)
  if (nargin > 1)
    print_usage ();
  end

  y = ellipticK (1 - m);

end


%!error <Invalid> ellipticCK (sym (1), 2)

%!assert (double (ellipticCK (sym (1)/2)), 1.8541, 10e-5)
%!assert (double (ellipticCK (sym (101)/10)), 0.812691836806976, -3*eps)
%!assert (isequal (ellipticCK (sym (1)), sym(pi)/2))
