%% Copyright (C) 2014, 2016-2017 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{S} =} svd (@var{A})
%% @deftypemethodx @@sym {[@var{U}, @var{S}, @var{V}] =} svd (@var{A})
%% @deftypemethodx @@sym {[@var{U}, @var{S}, @var{V}] =} svd (@var{A}, 'econ')
%% Symbolic singular value decomposition.
%%
%% The SVD is the factorization of matrix
%% @iftex
%% @math{A} into @math{U S V^T = A},
%% where @math{S} is a diagonal matrix of @emph{singular values},
%% and @math{U} and @math{V}
%% @end iftex
%% @ifnottex
%% A into U*S*V' = A,
%% where S is a diagonal matrix of @emph{singular values},
%% and U and V
%% @end ifnottex
%% are orthogonal matrices whose columns form the left and right
%% @emph{singular vectors}.
%%
%% When the matrix contains symbols, expressions, rational numbers, and other
%% things, this command finds the singular values via symbolic manipulation:
%% @example
%% @group
%% A = sym([1 0; 3 0]);
%% svd(A)
%%   @result{} (sym 2×1 matrix)
%%
%%       ⎡√10⎤
%%       ⎢   ⎥
%%       ⎣ 0 ⎦
%%
%% @end group
%% @end example
%% Currently only the singular values (not the singular vectors) are supported
%% in symbolic mode.
%%
%%
%% If the matrix contains Float entries (@pxref{vpa}) (and possibly Integers),
%% the SVD is computing numerically in variable precision
%% arithmetic in the precision given by @pxref{digits}.
%% The singular values and singular vectors can be computed in this mode.
%% Example:
%% @example
%% @group
%% A = vpa (3*hilb (sym(3)));
%% [U, S, V] = svd (A)
%%   @result{} U = (sym 3×3 matrix)
%%       ...
%%   @result{} S = (sym 3×3 matrix)
%%       ...
%%   @result{} V = (sym 3×3 matrix)
%%       ...
%% @end group
%%
%% @group
%% diag(S)
%%   @result{} (sym 3×1 matrix)
%%       ⎡ 4.2249567813709618726124675083017 ⎤
%%       ⎢                                   ⎥
%%       ⎢ 0.3669811975617175396944034278698 ⎥
%%       ⎢                                   ⎥
%%       ⎣0.008062021067320587693129063828546⎦
%% @end group
%% @end example
%%
%% Next, extract one singular value and associated left/right
%% singular vectors:
%% @example
%% @group
%% sv = S(1, 1)
%% u = U(:, 1)
%% v = V(:, 1)
%%   @result{} sv = (sym) 4.2249567813709618726124675083017
%%   @result{} u = (sym 3×1 matrix)
%%       ⎡-0.82704492697200940922027703647284⎤
%%       ⎢                                   ⎥
%%       ⎢-0.45986390436554392104852568981886⎥
%%       ⎢                                   ⎥
%%       ⎣-0.32329843524449897629157179151973⎦
%%   @result{} v = (sym 3×1 matrix)
%%       ⎡-0.82704492697200940922027703647284⎤
%%       ⎢                                   ⎥
%%       ⎢-0.45986390436554392104852568981886⎥
%%       ⎢                                   ⎥
%%       ⎣-0.32329843524449897629157179151973⎦
%% @end group
%% @end example
%%
%% Check the SVD is satisfied to high-precision:
%% @example
%% @group
%% sv*u - A*v
%%   @result{} (sym 3×1 matrix)
%%       ⎡-9.2444637330587320946686941244077e-33⎤
%%       ⎢                                      ⎥
%%       ⎢-3.0814879110195773648895647081359e-33⎥
%%       ⎢                                      ⎥
%%       ⎣-3.0814879110195773648895647081359e-33⎦
%% @end group
%% @end example
%%
%% If the @qcode{'econ'} keyboard is passed, an ``economy size''
%% SVD is returned (@pxref{svd}).
%% @seealso{svd, @@sym/eig}
%% @end deftypemethod


function [S, varargout] = svd(A, econ)

  if (nargin == 1)
    econ = false;
  elseif (nargin == 2)
    if (isnumeric(econ) && econ == 0)
      error('svd: auto econ mode ("0") is not yet supported')
    else
      econ = true;
    end
  else
    print_usage ();
  end

  if (nargout <= 1)
    svecs = false;
  elseif (nargout == 3)
    svecs = true;
  else
    print_usage ();
  end


  cmd = { 'A, = _ins'
          'A = A if A.is_Matrix else Matrix([A])'
          'return (any([x.is_Float for x in A]) and'
          '       all([x.is_Float or x.is_Integer for x in A]))' };
  is_vpa_matrix = python_cmd (cmd, sym(A));

  if (is_vpa_matrix)
    myd = digits ();  % TODO: or take from the object itself
    cmd = { '(A, svecs, econ, digits) = _ins'
            'A = A if A.is_Matrix else Matrix([A])'
            'import mpmath'
            'mpmath.mp.dps = digits'
            'tmp = mpmath.svd(mpmath.matrix(A), full_matrices=(not econ), compute_uv=svecs)'
            'if svecs:'
            '    (U, S, Vt) = tmp'
            '    U = Matrix(U.rows, U.cols, lambda i,j: U[i, j])'
            '    S = Matrix(S)'
            '    m, n = A.shape'
            '    r, c = (m, n) if not econ else (min(m,n),)*2'
            '    S = Matrix(r, c, lambda i,j: S[i] if i == j else 0)'
            '    V = Vt.transpose()'  % TODO: or transpose_conj?
            '    V = Matrix(V.rows, V.cols, lambda i,j: V[i, j])'
            'else:'
            '    S = Matrix(tmp)'
            '    U, V = None, None'
            'return (U, S, V)' };
    [U, S, V] = python_cmd (cmd, sym(A), svecs, econ, myd);

    if (nargout >= 2)
      varargout{1} = S;
      varargout{2} = V;
      S = U;
    end

  else
    if (svecs)
      error ('svd: singular vectors not yet implemented for non-vpa matrices')
    end
    if (econ)
      error ('svd: "economy size" not yet implemented for non-vpa matrices')
    end

  cmd = { '(A,) = _ins'
          'if not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'L = sp.Matrix(A.singular_values())'
          'return L,' };

  S = python_cmd (cmd, sym(A));
  end
end


%!error <Invalid> svd (sym(1), 2, 3)
%!error <Invalid> [a, b] = svd (sym(1))

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

%!test
%! % econ & non-square matrices
%! A = vpa([1 2 4; 1 2 4]);
%! S = svd (A);
%! assert (size (S), [2 1])
%! [U, S, V] = svd (A);
%! assert (size (U), [2 2])
%! assert (size (S), [2 3])
%! assert (size (V), [3 3])
%! [U, S, V] = svd (A, 'econ');
%! assert (size (U), [2 2])
%! assert (size (S), [2 2])
%! assert (size (V), [3 2])
%! A = A';
%! S = svd (A);
%! assert (size (S), [2 1])
%! [U, S, V] = svd (A, 'econ');
%! assert (size (U), [3 2])
%! assert (size (S), [2 2])
%! assert (size (V), [2 2])
%! [U, S, V] = svd (A);
%! assert (size (U), [3 3])
%! assert (size (S), [3 2])
%! assert (size (V), [2 2])
