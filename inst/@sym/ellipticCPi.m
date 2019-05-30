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
%% @defmethod @@sym ellipticCPi (@var{nu}, @var{m})
%% Complementary complete elliptic integral of the third kind.
%%
%% This is the complete elliptic integral (of the third kind) with the
%% complementary parameter @code{1 - @var{m}}:
%% @example
%% @group
%% syms nu m
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% ellipticCPi (nu, m)
%%   @result{} ans = (sym) Π(ν│1 - m)
%% @end group
%% @end example
%%
%% Examples:
%% @example
%% @group
%% ellipticCPi (nu, sym(1)/4)
%%   @result{} ans = (sym) Π(ν│3/4)
%% @end group
%%
%% @group
%% ellipticCPi (sym(1)/2, sym(1)/4)
%%   @result{} ans = (sym) Π(1/2│3/4)
%% vpa (ans)
%%   @result{} (sym) 3.2347734712494648531580124982005
%% @end group
%% @end example
%%
%% There are other conventions for the inputs of elliptic integrals,
%% @pxref{@@sym/ellipticF}.
%%
%% @seealso{@@sym/ellipticPi}
%% @end defmethod


function y = ellipticCPi(n, m)
  if (nargin ~= 2)
    print_usage ();
  end

  y = ellipticPi (n, sym (pi)/2, 1 - m);

end

%!error <Invalid> ellipticCPi (sym (1))
%!error <Invalid> ellipticCPi (sym (1), 2, 3)

%!assert (double (ellipticCPi (0, sym (1)/2)), 1.854074677, 10e-10)

%!assert (double (ellipticCPi (sym (6)/10, sym(71)/10)), 1.29469534336658, -20*eps)
