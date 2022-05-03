%% Copyright (C) 2022 Alex Vong
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
%% If not, see <https://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod  @@sym ztrans (@var{f}, @var{n}, @var{z})
%% @defmethodx @@sym ztrans (@var{f})
%% @defmethodx @@sym ztrans (@var{f}, @var{z})
%% Symbolic one-sided Z-transform.
%%
%% The one-sided Z-transform of a function @var{f} of @var{n}
%% is a function @var{X} of @var{z} defined by the Laurent series below.
%% @example
%% @group
%% syms n nonnegative integer
%% syms f(n)
%% syms z nonzero complex
%% X(z) = ztrans (f)
%%   @result{} X(z) = (symfun)
%%         ∞
%%        ___
%%        ╲
%%         ╲    -n
%%         ╱   z  ⋅f(n)
%%        ╱
%%        ‾‾‾
%%       n = 0
%% @end group
%% @end example
%%
%%
%% Example:
%% @example
%% @group
%% syms n
%% f = n^2;
%% ztrans (f)
%%   @result{} (sym)
%%       ⎧        1
%%       ⎪   -1 - ─
%%       ⎪        z          1
%%       ⎪───────────   for ─── < 1
%%       ⎪          3       │z│
%%       ⎪  ⎛     1⎞
%%       ⎪z⋅⎜-1 + ─⎟
%%       ⎪  ⎝     z⎠
%%       ⎨
%%       ⎪  ∞
%%       ⎪ ___
%%       ⎪ ╲
%%       ⎪  ╲    2  -n
%%       ⎪  ╱   n ⋅z     otherwise
%%       ⎪ ╱
%%       ⎪ ‾‾‾
%%       ⎩n = 0
%% @end group
%% @end example
%%
%% By default the output is a function of @code{z} (or @code{w} if @code{z} is
%% an independent variable of @code{f}).  This can be overridden by specifying
%% @var{z}.  For example:
%% @example
%% @group
%% syms n z w
%% ztrans (exp (n))
%%   @result{} (sym)
%%       ⎧     1             ℯ
%%       ⎪   ─────      for ─── < 1
%%       ⎪       ℯ          │z│
%%       ⎪   1 - ─
%%       ⎪       z
%%       ⎪
%%       ⎪  ∞
%%       ⎨ ___
%%       ⎪ ╲
%%       ⎪  ╲    -n  n
%%       ⎪  ╱   z  ⋅ℯ    otherwise
%%       ⎪ ╱
%%       ⎪ ‾‾‾
%%       ⎪n = 0
%%       ⎩
%% ztrans (exp (z))
%%   @result{} (sym)
%%       ⎧     1             ℯ
%%       ⎪   ─────      for ─── < 1
%%       ⎪       ℯ          │w│
%%       ⎪   1 - ─
%%       ⎪       w
%%       ⎪
%%       ⎪  ∞
%%       ⎨ ___
%%       ⎪ ╲
%%       ⎪  ╲    -z  z
%%       ⎪  ╱   w  ⋅ℯ    otherwise
%%       ⎪ ╱
%%       ⎪ ‾‾‾
%%       ⎪z = 0
%%       ⎩
%% ztrans (exp (n), w)
%%   @result{} (sym)
%%       ⎧     1             ℯ
%%       ⎪   ─────      for ─── < 1
%%       ⎪       ℯ          │w│
%%       ⎪   1 - ─
%%       ⎪       w
%%       ⎪
%%       ⎪  ∞
%%       ⎨ ___
%%       ⎪ ╲
%%       ⎪  ╲    -n  n
%%       ⎪  ╱   w  ⋅ℯ    otherwise
%%       ⎪ ╱
%%       ⎪ ‾‾‾
%%       ⎪n = 0
%%       ⎩
%% @end group
%% @end example
%%
%% If not specified by @var{n}, the independent variable is chosen by
%% looking for a symbol named @code{n}.  If no such symbol is found,
%% @pxref{@@sym/symvar} is used, which choses a variable close to @code{x}:
%% @example
%% @group
%% syms a n y
%% ztrans (n * exp (y))
%%   @result{} (sym)
%%       ⎛⎧    1             1     ⎞
%%       ⎜⎪──────────   for ─── < 1⎟
%%       ⎜⎪         2       │z│    ⎟
%%       ⎜⎪  ⎛    1⎞               ⎟
%%       ⎜⎪z⋅⎜1 - ─⎟               ⎟
%%       ⎜⎪  ⎝    z⎠               ⎟
%%       ⎜⎪                        ⎟  y
%%       ⎜⎨  ∞                     ⎟⋅ℯ
%%       ⎜⎪ ___                    ⎟
%%       ⎜⎪ ╲                      ⎟
%%       ⎜⎪  ╲      -n             ⎟
%%       ⎜⎪  ╱   n⋅z     otherwise ⎟
%%       ⎜⎪ ╱                      ⎟
%%       ⎜⎪ ‾‾‾                    ⎟
%%       ⎝⎩n = 0                   ⎠
%% ztrans (a * exp (y))
%%   @result{} (sym)
%%         ⎛⎧     1             ℯ     ⎞
%%         ⎜⎪   ─────      for ─── < 1⎟
%%         ⎜⎪       ℯ          │z│    ⎟
%%         ⎜⎪   1 - ─                 ⎟
%%         ⎜⎪       z                 ⎟
%%         ⎜⎪                         ⎟
%%         ⎜⎪  ∞                      ⎟
%%       a⋅⎜⎨ ___                     ⎟
%%         ⎜⎪ ╲                       ⎟
%%         ⎜⎪  ╲    -y  y             ⎟
%%         ⎜⎪  ╱   z  ⋅ℯ    otherwise ⎟
%%         ⎜⎪ ╱                       ⎟
%%         ⎜⎪ ‾‾‾                     ⎟
%%         ⎜⎪y = 0                    ⎟
%%         ⎝⎩                         ⎠
%% @end group
%% @end example
%%
%% @var{f}, @var{n} and @var{z} can be scalars or matrices of the same size.
%% Scalar inputs are first expanded to matrices to match the size of the
%% non-scalar inputs.  Then @code{ztrans} will be applied elementwise.
%% @example
%% @group
%% syms n m k c z w u v
%% f = [n^2 exp(n); 1/factorial(k) kroneckerDelta(c)];
%% ztrans (f, [n m; k c], [z w; u v])
%%   @result{} (sym 2×2 matrix)
%%       ⎡⎧        1                                              ⎤
%%       ⎢⎪   -1 - ─                  ⎛⎧    1           1     ⎞   ⎥
%%       ⎢⎪        z          1       ⎜⎪  ─────    for ─── < 1⎟   ⎥
%%       ⎢⎪───────────   for ─── < 1  ⎜⎪      1        │w│    ⎟   ⎥
%%       ⎢⎪          3       │z│      ⎜⎪  1 - ─               ⎟   ⎥
%%       ⎢⎪  ⎛     1⎞                 ⎜⎪      w               ⎟   ⎥
%%       ⎢⎪z⋅⎜-1 + ─⎟                 ⎜⎪                      ⎟   ⎥
%%       ⎢⎪  ⎝     z⎠                 ⎜⎪  ∞                   ⎟  n⎥
%%       ⎢⎨                           ⎜⎨ ___                  ⎟⋅ℯ ⎥
%%       ⎢⎪  ∞                        ⎜⎪ ╲                    ⎟   ⎥
%%       ⎢⎪ ___                       ⎜⎪  ╲    -m             ⎟   ⎥
%%       ⎢⎪ ╲                         ⎜⎪  ╱   w     otherwise ⎟   ⎥
%%       ⎢⎪  ╲    2  -n               ⎜⎪ ╱                    ⎟   ⎥
%%       ⎢⎪  ╱   n ⋅z     otherwise   ⎜⎪ ‾‾‾                  ⎟   ⎥
%%       ⎢⎪ ╱                         ⎜⎪m = 0                 ⎟   ⎥
%%       ⎢⎪ ‾‾‾                       ⎝⎩                      ⎠   ⎥
%%       ⎢⎩n = 0                                                  ⎥
%%       ⎢                                                        ⎥
%%       ⎢             1                                          ⎥
%%       ⎢             ─                                          ⎥
%%       ⎢             u                                          ⎥
%%       ⎣            ℯ                            1              ⎦
%% ztrans (f, [n m; k c], z)
%%   @result{} (sym 2×2 matrix)
%%       ⎡⎧        1                                              ⎤
%%       ⎢⎪   -1 - ─                  ⎛⎧    1           1     ⎞   ⎥
%%       ⎢⎪        z          1       ⎜⎪  ─────    for ─── < 1⎟   ⎥
%%       ⎢⎪───────────   for ─── < 1  ⎜⎪      1        │z│    ⎟   ⎥
%%       ⎢⎪          3       │z│      ⎜⎪  1 - ─               ⎟   ⎥
%%       ⎢⎪  ⎛     1⎞                 ⎜⎪      z               ⎟   ⎥
%%       ⎢⎪z⋅⎜-1 + ─⎟                 ⎜⎪                      ⎟   ⎥
%%       ⎢⎪  ⎝     z⎠                 ⎜⎪  ∞                   ⎟  n⎥
%%       ⎢⎨                           ⎜⎨ ___                  ⎟⋅ℯ ⎥
%%       ⎢⎪  ∞                        ⎜⎪ ╲                    ⎟   ⎥
%%       ⎢⎪ ___                       ⎜⎪  ╲    -m             ⎟   ⎥
%%       ⎢⎪ ╲                         ⎜⎪  ╱   z     otherwise ⎟   ⎥
%%       ⎢⎪  ╲    2  -n               ⎜⎪ ╱                    ⎟   ⎥
%%       ⎢⎪  ╱   n ⋅z     otherwise   ⎜⎪ ‾‾‾                  ⎟   ⎥
%%       ⎢⎪ ╱                         ⎜⎪m = 0                 ⎟   ⎥
%%       ⎢⎪ ‾‾‾                       ⎝⎩                      ⎠   ⎥
%%       ⎢⎩n = 0                                                  ⎥
%%       ⎢                                                        ⎥
%%       ⎢             1                                          ⎥
%%       ⎢             ─                                          ⎥
%%       ⎢             z                                          ⎥
%%       ⎣            ℯ                            1              ⎦
%% @end group
%% @end example
%%
%% As of sympy 1.10.1, sympy cannot find the closed form of one-sided
%% Z-transform involving trigonometric functions and Heaviside step function.
%% @example
%% @group
%% syms n
%% ztrans (cos (n))
%%   @result{} (sym)
%%         ∞
%%        ___
%%        ╲
%%         ╲    -n
%%         ╱   z  ⋅cos(n)
%%        ╱
%%        ‾‾‾
%%       n = 0
%% ztrans (heaviside (n - 3))
%%   @result{} (sym)
%%         ∞
%%        ___
%%        ╲
%%         ╲    -n
%%         ╱   z  ⋅θ(n - 3)
%%        ╱
%%        ‾‾‾
%%       n = 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/iztrans}
%% @end defmethod

%% Author: Alex Vong
%% Keywords: symbolic

function X = ztrans (varargin)
  if (nargin > 3 || nargin == 0)
    print_usage ();
  end

  %% ensure all inputs are sym
  if ~all (cellfun (@(x) isa (x, 'sym'), varargin))
    inputs = cellfun (@sym, varargin, 'UniformOutput', false);
    X = ztrans (inputs{:});
    return
  end

  %% recursively call ztrans for non-scalar inputs
  if ~all (cellfun (@isscalar, varargin))
    inputs = cellfun (@(x) num2cell (x), varargin, 'UniformOutput', false);
    X = sym (cellfun (@ztrans, inputs{:}, 'UniformOutput', false));
    return
  end

  f = sym (varargin{1});
  f_vars = findsymbols (f);
  find_var_from_f = @(v) f_vars (cellfun (@(x) strcmp (char (x), v), f_vars));

  %% select var n
  if (nargin == 3)
    n = sym (varargin{2});
  else
    ns = find_var_from_f ('n');
    assert (numel (ns) <= 1, 'ztrans: there is more than one "n" symbol: check symvar (f) and sympy (f)');
    if (~isempty (ns))
      n = ns{:}; % use var n from f
    elseif (~isempty (f_vars))
      n = symvar (f, 1); % select var from f using symfun
    else
      n = sym ('n', 'nonnegative', 'integer'); % use freshly generated var n
    end
  end

  %% select var z
  if (nargin == 3)
    z = sym (varargin{3});
  elseif (nargin == 2)
    z = sym (varargin{2});
  else
    zs = find_var_from_f ('z');
    if (isempty (zs)) % use var z if f is a not function of z
      z = sym ('z');
    else % use var w if f is a function of z
      z = sym ('w');
    end
  end

  X = symsum (f / z^n, n, 0, inf);
end

%% Z-transform table:
%% https://en.wikipedia.org/wiki/Z-transform#Table_of_common_Z-transform_pairs

%!test
%! % basic Z-transform table checks
%! % X1, ..., X4 must have inner radius of convergence 1
%! syms n z
%! % trick to extract the closed form formula using the fact that inner roc = 1
%! closed_form = @(X) subs (X, abs (z), 2);
%! % check if ztrans(f) == X
%! check_ztrans = @(f, X) logical (simplify (closed_form (ztrans (f)) == X));
%! f1 = sym (1);
%! X1 = 1 / (1 - 1 / z);
%! assert (check_ztrans (f1, X1));
%! f2 = n;
%! X2 = (1 / z) / (1 - 1 / z)^2;
%! assert (check_ztrans (f2, X2));
%! f3 = n^2;
%! X3 = (1 / z) * (1 + 1 / z) / (1 - 1 / z)^3;
%! assert (check_ztrans (f3, X3));
%! f4 = n^3;
%! X4 = (1 / z) * (1 + 4 / z + 1 / z^2) / (1 - 1 / z)^4;
%! assert (check_ztrans (f4, X4));
%! % basic matrix checks
%! A1 = ztrans ([f1 f2; f3 f4]);
%! B1 = [ztrans(f1) ztrans(f2); ztrans(f3) ztrans(f4)];
%! assert (isequal (A1, B1));
%! A2 = ztrans ([f1 f2; f3 f4], z);
%! B2 = [ztrans(f1, z) ztrans(f2, z); ztrans(f3, z) ztrans(f4, z)];
%! assert (isequal (A2, B2));
%! A3 = ztrans ([f1 f2; f3 f4], n, z);
%! B3 = [ztrans(f1, n, z) ztrans(f2, n, z); ztrans(f3, n, z) ztrans(f4, n, z)];
%! assert (isequal (A3, B3));

%!test
%! % additional Z-transform table checks
%! % X1, ..., X4 must have inner radius of convergence a
%! syms n nonnegative integer
%! syms m positive integer
%! syms a
%! syms z
%! % trick to extract the closed form formula using the fact that inner roc = a
%! closed_form = @(X) subs (X, abs (a / z), 1 / sym (2));
%! % check if ztrans(f) == X
%! check_ztrans = @(f, X) logical (simplify (closed_form (ztrans (f)) == X));
%! f1 = a^n;
%! X1 = 1 / (1 - a / z);
%! assert (check_ztrans (f1, X1));
%! f2 = n * a^n;
%! X2 = (a / z) / (1 - a / z)^2;
%! assert (check_ztrans (f2, X2));
%! f3 = n^2 * a^n;
%! X3 = (a / z) * (1 + a / z) / (1 - a / z)^3;
%! assert (check_ztrans (f3, X3));
%! f4 = nchoosek(n + m - 1, m - 1) * a^n;
%! X4 = 1 / (1 - a / z)^m;
%! assert (check_ztrans (f4, X4));
%! % additional matrix checks
%! A1 = ztrans (f1, [n m; m n], [z a; a z]);
%! B1 = [ztrans(f1, n, z) ztrans(f1, m, a); ztrans(f1, m, a) ztrans(f1, n, z)];
%! assert (isequal (A1, B1));
%! A2 = ztrans (f1, m, [z a; a z]);
%! B2 = [ztrans(f1, m, z) ztrans(f1, m, a); ztrans(f1, m, a) ztrans(f1, m, z)];
%! assert (isequal (A2, B2));
%! A3 = ztrans (f1, [n m; m n], a);
%! B3 = [ztrans(f1, n, a) ztrans(f1, m, a); ztrans(f1, m, a) ztrans(f1, n, a)];
%! assert (isequal (A3, B3));

%!test
%! % Kronecker delta checks
%! syms n n0 nonnegative integer
%! syms z
%! assert (isequal (ztrans (kroneckerDelta (n)), 1));
%! assert (isequal (ztrans (kroneckerDelta (n - n0)), 1 / z^n0));

%!test
%! % basic var selection checks
%! syms n m z w
%! assert (isequal (ztrans (1 / factorial (n)), exp (1 / z)));
%! assert (isequal (ztrans (1 / factorial (z)), exp (1 / w)));
%! assert (isequal (ztrans (1 / factorial (m), w), exp (1 / w)));
%! assert (isequal (ztrans (1 / factorial (m), m, w), exp (1 / w)));

%!test
%! % additional var selection checks
%! syms n m z
%! f = kroneckerDelta(m) / factorial (n);
%! assert (isequal (ztrans (f, z), exp (1 / z) * kroneckerDelta (m)));
%! assert (isequal (ztrans (f, n, z), exp (1 / z) * kroneckerDelta (m)));
%! assert (isequal (ztrans (f, m, z), 1 / factorial (n)));

%!test
%! % if no t, use symvar: take x before a
%! syms a x z
%! assert (isequal (ztrans (a / factorial (x)), a * exp (1 / z)));

%!error <more than one> ztrans (sym ('n')^sym ('n', 'nonnegative', 'integer'))
