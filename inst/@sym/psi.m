%% Copyright (C) 2015, 2016, 2018 Colin B. Macdonald
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
%% @defmethod  @@sym psi (@var{x})
%% @defmethodx @@sym psi (@var{k}, @var{x})
%% Symbolic polygamma function.
%%
%% The first polygamma (or ``psi'') function is the logarithmic
%% derivative of the gamma function:
%% @example
%% @group
%% syms x
%% psi(x)
%%   @result{} (sym) polygamma(0, x)
%% diff(log(gamma(x)))
%%   @result{} (sym) polygamma(0, x)
%% @end group
%% @end example
%%
%% More generally, we have the @var{k}+1 derivative:
%% @example
%% @group
%% psi(1, x)
%%   @result{} (sym) polygamma(1, x)
%% diff(psi(x))
%%   @result{} (sym) polygamma(1, x)
%% diff(log(gamma(x)), 2)
%%   @result{} (sym) polygamma(1, x)
%% @end group
%% @end example
%%
%% @seealso{psi, @@sym/gamma, @@sym/gammainc}
%% @end defmethod

function W = psi(k, x)
  if (nargin == 1)
    x = k;
    k = 0;
  elseif (nargin == 2)
    % no-op
  else
    print_usage ();
  end

  W = elementwise_op ('polygamma', sym(k), sym(x));

end


%!assert (isequal (psi (sym (1)), -eulergamma))
%!assert (isequal (psi (1, sym (1)), sym (pi)^2/6))
%!assert (isinf (psi (sym ('inf'))))

%!test
%! % compare to Maple: evalf(Psi(-101/100));
%! maple = vpa ('100.3963127058453949545769053445198842332424', 40);
%! us = vpa (psi (sym (-101)/100), 40);
%! assert (abs(double(maple-us)) < 1e-39)

%!test
%! % compare to Maple: evalf(Psi(1, 3*I-2));
%! maple = vpa ('-0.1651414829219882371561038184133243839778799', 40) - ...
%!         vpa ('0.1960040752985823275302034466611711263617296j', 40);
%! us = vpa (psi (1, sym (-2) + sym(3i)), 40);
%! assert (abs(double(maple-us)) < 1e-39)

%!test
%! % should match @double/psi
%! if (exist ('psi','builtin'))
%! assert (psi (pi),    double (psi (sym (pi))),    -3*eps)
%! assert (psi (100),   double (psi (sym (100))),   -3*eps)
%! assert (psi (1e-3),  double (psi (1/sym (1e3))), -3*eps)
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! % 2014a doesn't support negative or complex arguments
%! assert (psi (-1.5),  double (psi (sym (-3)/2)),  -3*eps)
%! assert (psi (-8.3),  double (psi (sym (-83)/10)),-4*eps)
%! assert (psi (2i),    double (psi (sym (2i))),    -3*eps)
%! assert (psi (10i+3), double (psi (sym (10i)+3)), -3*eps)
%! end
%! end

%!test
%! % @double/psi loses accuracy near the poles: note higher rel tol
%! if (exist ('psi','builtin'))
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! assert (psi (-1.1),  double (psi (sym (-11)/10)), -6*eps)
%! assert (psi (-1.01), double (psi (sym (-101)/100)), -50*eps)
%! end
%! end

% 2016-05: for k>0, @double/psi only does real positive

%!test
%! if (exist ('psi','builtin'))
%! assert (psi (1, pi),   double (psi (1, sym (pi))),    -3*eps)
%! assert (psi (1, 100),  double (psi (1, sym (100))),   -3*eps)
%! assert (psi (1, 1e-4), double (psi (1, 1/sym (1e4))), -3*eps)
%! end

%!test
%! if (exist ('psi','builtin'))
%! assert (psi (2, pi),   double (psi (2, sym (pi))), -3*eps)
%! assert (psi (2, 1000), double (psi (2, sym (1000))), -3*eps)
%! assert (psi (2, 1e-4), double (psi (2, 1/sym (1e4))), -3*eps)
%! end

%!test
%! % round trip
%! if (exist ('psi','builtin'))
%! syms x
%! f = psi (x);
%! h = function_handle (f);
%! A = h (1.1);
%! B = psi (1.1);
%! assert (A, B)
%! end
