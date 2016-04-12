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
%% @deftypefn  {Function File} {@var{A} =} airy (@var{k}, @var{x})
%% @deftypefnx {Function File} {@var{A} =} airy (@var{x})
%% Symbolic Airy functions of first/second kind and their derivatives.
%%
%% @var{k} can be 0, 1, 2, or 3, @ref{airy}.
%%
%% Examples:
%% @example
%% @group
%% syms z
%% Ai = airy(0, z)
%%   @result{} Ai = (sym) airyai(z)
%%
%% Bi = airy(2, z)
%%   @result{} Bi = (sym) airybi(z)
%%
%% Bi_prime = airy(3, z)
%%   @result{} Bi_prime = (sym) airybi′(z)
%%
%% diff(Bi, z)
%%   @result{} (sym) airybi′(z)
%%
%% diff(Bi, z, z)
%%   @result{} (sym) z⋅airybi(z)
%% @end group
%% @end example
%%
%% @seealso{besselj, bessely, besseli, besselk, besselh}
%% @end deftypefn

function A = airy(k, x)

  if (nargin == 2)
    % no-op
  elseif (nargin == 1)
    x = k;
    k = 0;
  else
    print_usage ();
  end

  assert(isscalar(k))

  if (logical(k == 0))
    A = uniop_helper(x, 'airyai');
  elseif (logical(k == 1))
    A = uniop_helper(x, 'airyaiprime');
  elseif (logical(k == 2))
    A = uniop_helper(x, 'airybi');
  elseif (logical(k == 3))
    A = uniop_helper(x, 'airybiprime');
  else
    error('airy: expecting K = 0, 1, 2, or 3')
  end

end


%!test
%! syms z
%! a = airy(0, z);
%! ap = airy(1, z);
%! assert (isequal (diff (a), ap))
%! assert (isequal (diff (ap), z*a))

%!test
%! syms z
%! b = airy(2, z);
%! bp = airy(3, z);
%! assert (isequal (diff (b), bp))
%! assert (isequal (diff (bp), z*b))

%!test
%! % default to k=0
%! syms z
%! a = airy(0, z);
%! a2 = airy(z);
%! assert (isequal (a, a2))

%!error airy(0, sym('x'), 2)
%!error <expecting K = 0, 1, 2, or 3> airy(4, sym('z'))
%!error <expecting K = 0, 1, 2, or 3> airy(-1, sym('z'))

%!test
%! % symbolic k
%! syms z
%! b1 = airy(2, z);
%! b2 = airy(sym(2), z);
%! assert (isequal (b1, b2))

%!test
%! % doubles, relative error
%! X = [1 2 pi; 4i 5 6+6i];
%! Xs = sym(X);
%! for k = 0:3
%!   A = double(airy(k, Xs));
%!   B = airy(k, X);
%!   assert (all (all (abs(A - B) < 500*eps*abs(A))))
%! end

%!test
%! % round-trip
%! if (python_cmd ('return Version(spver) >= Version("1.0")'))
%! syms x
%! for k = 0:3
%!   A = airy(k, 10);
%!   q = airy(k, x);
%!   h = function_handle(q);
%!   B = h(10);
%!   assert (abs(A-B) < 500*eps*abs(A))
%! end
%! end
