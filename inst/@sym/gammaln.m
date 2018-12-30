%% Copyright (C) 2016, 2018 Colin B. Macdonald
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

function y = gammaln(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('loggamma', x);
end


%!assert (isequal (gammaln (sym (3)), log (sym (2))))
%!assert (isequal (gammaln (sym (10)), log (gamma (sym (10)))))

%!test
%! % compare to Maple: evalf(lnGAMMA(Pi));
%! maple = vpa ('0.827694592323437101529578558452359951153502', 40);
%! us = vpa (gammaln (sym(pi)), 40);
%! assert (abs(double(maple-us)) < 1e-39)

%!test
%! % compare to Maple: evalf(lnGAMMA(3+2*I));
%! maple = vpa ('-0.0316390593739611898037677296008797172022603', 40) + ...
%!         vpa ('2.02219319750132712401643376238334982100512j', 40);
%! us = vpa (gammaln (sym(3) + 2i), 40);
%! assert (abs(double(maple-us)) < 1e-39)

%!test
%! % compare to Maple: evalf(lnGAMMA(-1.5));
%! % notably, @double/gammaln has zero imag part
%! maple = vpa ('0.8600470153764810145109326816703567873271571', 40) - ...
%!         vpa ('6.2831853071795864769252867665590057683943388j', 40);
%! us = vpa (gammaln (-sym(3)/2), 40);
%! assert (abs(double(maple-us)) < 1e-39)

% should match @double/gammaln
%!assert (gammaln (pi),    double (gammaln (sym (pi))),    -3*eps)
%!assert (gammaln (100),   double (gammaln (sym (100))),   -3*eps)
% failed at -3*eps on one system: Windows 10, Atom 64bit.
%!assert (gammaln (1e-3),  double (gammaln (1/sym (1e3))), -100*eps)

%!test
%! % round trip
%! syms x
%! f = gammaln (x);
%! h = function_handle (f);
%! A = h (1.1);
%! B = gammaln (1.1);
%! assert (A, B)
