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
%% @deftypefn  {Function File} {@var{S} =} svd (@var{A})
%% @deftypefnx {Function File} {@var{U}, @var{S}, @var{V} =} svd (@var{A})
%% Symbolic singular value decomposition.
%%
%% The SVD:
%% U*S*V' = A
%%
%% FIXME: currently only singular values, not singular vectors.
%% Should add full SVD to sympy.
%%
%% @seealso{eig}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [S, varargout] = svd(A)

  if (nargin >= 2)
    error('svd: economy-size not supported yet')
  end

  if (nargout >= 2)
    error('svd: singular vectors not yet computed by sympy')
  end

  cmd = { '(A,) = _ins'
          'if not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'L = sp.Matrix(A.singular_values())'
          'return L,' };

  S = python_cmd (cmd, sym(A));

end


%!test
%! % basic
%! A = [1 2; 3 4];
%! B = sym(A);
%! sd = svd(A);
%! s = svd(B);
%! s2 = double(s);
%! assert (norm(s2 - sd) <= 10*eps)

%!test
%! % scalars
%! syms x
%! syms y positive
%! a = sym(-10);
%! assert (isequal (svd(a), sym(10)))
%! assert (isequal (svd(x), sqrt(x*conj(x))))
%! assert (isequal (svd(y), y))

%!test
%! % matrix with symbols
%! syms x positive
%! A = [x+1 0; sym(0) 2*x+1];
%! s = svd(A);
%! s2 = subs(s, x, 2);
%! assert (isequal (s2, [sym(5); 3]))
%! s = simplify(factor(s));
%! assert (isequal (s, [2*x+1; x+1]))

%%!test
%%! % no sing vecs
%%! A = [x 0; sym(0) 2*x]
%%! [u,s,v] = cond(A)
%%! assert (false)
