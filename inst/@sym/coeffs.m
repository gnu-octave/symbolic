%% Copyright (C) 2014-2017, 2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{c} =} coeffs (@var{p}, @var{x})
%% @deftypemethodx @@sym {@var{c} =} coeffs (@var{p})
%% @deftypemethodx @@sym {@var{c} =} coeffs (@dots{}, 'all')
%% @deftypemethodx @@sym {[@var{c}, @var{t}] =} coeffs (@var{p}, @var{x})
%% @deftypemethodx @@sym {[@var{c}, @var{t}] =} coeffs (@var{p})
%% @deftypemethodx @@sym {[@var{c}, @var{t}] =} coeffs (@dots{}, 'all')
%% Return non-zero (or all) coefficients of symbolic polynomial.
%%
%% @var{c} contains the coefficients and @var{t} the corresponding
%% terms.
%%
%% Example:
%% @example
%% @group
%% syms x
%% [c, t] = coeffs (x^6 + 3*x - 4)
%%   @result{} c = (sym) [1  3  -4]  (1×3 matrix)
%%   @result{} t = (sym 1×3 matrix)
%%        ⎡ 6      ⎤
%%        ⎣x   x  1⎦
%% @end group
%% @end example
%%
%% The polynomial can be multivariate:
%% @example
%% @group
%% syms x y
%% [c, t] = coeffs (x^2 + y*x)
%%   @result{} c = (sym) [1  1]  (1×2 matrix)
%%   @result{} t = (sym 1×2 matrix)
%%       ⎡ 2     ⎤
%%       ⎣x   x⋅y⎦
%% @end group
%%
%% @group
%% [c, t] = coeffs (x^2 + y*x, [x y])   % same
%%   @result{} c = (sym) [1  1]  (1×2 matrix)
%%   @result{} t = (sym 1×2 matrix)
%%       ⎡ 2     ⎤
%%       ⎣x   x⋅y⎦
%%
%% [c, t] = coeffs (x^2 + y*x, @{x y@})   % same
%%   @result{} c = (sym) [1  1]  (1×2 matrix)
%%   @result{} t = (sym 1×2 matrix)
%%       ⎡ 2     ⎤
%%       ⎣x   x⋅y⎦
%% @end group
%% @end example
%%
%% You can use the second argument to specify a vector or list of
%% variables:
%% @example
%% @group
%% [c, t] = coeffs (x^2 + y*x, x)
%%   @result{} c = (sym) [1  y]  (1×2 matrix)
%%   @result{} t = (sym 1×2 matrix)
%%       ⎡ 2   ⎤
%%       ⎣x   x⎦
%% @end group
%% @end example
%%
%% Omitting the second output is not recommended, especially for non-interactive
%% code, because it gives only the non-zero coefficients, and additionally
%% the output is in the ``wrong order'' compared to other polynomial-related
%% commands:
%% @example
%% @group
%% c = coeffs (x^6 + 3*x - 4)
%%   @result{} c = (sym) [-4  3  1]  (1×3 matrix)
%% @end group
%% @end example
%% @strong{Warning:} Again, note the order is reversed from the two-output
%% case; this is for compatibility with Matlab's Symbolic Math Toolbox.
%%
%% If the optional input keyword @qcode{'all'} is passed, the zero
%% coefficients are returned as well, and in the familiar order.
%% @example
%% @group
%% c = coeffs (x^6 + 3*x - 4, 'all')
%%   @result{} c = (sym) [1  0  0  0  0  3  -4]  (1×7 matrix)
%% @end group
%% @end example
%% @strong{Note:} The @qcode{'all'} feature does not yet work with
%% multivariate polynomials (https://github.com/cbm755/octsympy/issues/720).
%%
%% @seealso{@@sym/sym2poly}
%% @end deftypemethod

function [c, t] = coeffs(p, x, all)

  if (nargin == 1)
    x = [];
    all = false;
  elseif (nargin == 2)
    if (ischar (x))
      assert (strcmpi (x, 'all'), ...
              'coeffs: invalid 2nd input: if string, should be "all"')
      x = [];
      all = true;
    else
      all = false;
    end
  elseif (nargin == 3)
    assert (strcmpi (all, 'all'), ...
            'coeffs: invalid 3rd input: should be string "all"')
    all = true;
  elseif (nargin > 3)
    print_usage ();
  end

  assert (isscalar (p), 'coeffs: works for scalar input only')

  p = sym(p);

  if (isempty (x))
    x = symvar (p);
    if (isempty (x))
      x = sym('x');  % any symbol
    end
  end

  x = sym(x);

  cmd = { '(f, xx, all) = _ins'
          'if not xx.is_Matrix:'
          '    xx = sp.Matrix([xx])'
          'xx = list(xx)'
          'p = Poly.from_expr(f, *xx)'
          'if all:'
          '    terms = p.all_terms()'
          'else:'
          '    terms = p.terms()'
          'cc = [q[1] for q in terms]'
          'tt = [1]*len(terms)'
          'for i, x in enumerate(p.gens):'
          '    tt = [t*x**q[0][i] for (t, q) in zip(tt, terms)]'
          'return (Matrix([cc]), Matrix([tt]))' };

  [c, t] = pycall_sympy__ (cmd, p, x, all);

  %% SMT compat:
  % reverse the order if t is not output.
  if (nargout <= 1) && (all == false)
    c = fliplr(c);
  end

  % if nargout == 1, its simplier to use 'p.coeffs()'
end


%!error <Invalid> coeffs (sym(1), 2, 3, 4)
%!error <should be> coeffs (sym(1), 2, 'al')
%!error <should be> coeffs (sym(1), 'al')

%!test
%! % simple
%! syms x
%! [c, t] = coeffs(6*x*x + 27);
%! assert (isequal (c, [6 27]))
%! assert (isequal (t, [x*x 1]))

%!test
%! % specify a variable
%! syms x
%! [c, t] = coeffs(6*x*x + 27, x);
%! assert (isequal (c, [6 27]))
%! assert (isequal (t, [x*x 1]))

%!test
%! % specify another variable
%! syms x y
%! [c, t] = coeffs(6*x + 27, y);
%! assert (isequal (c, 6*x + 27))
%! assert (isequal (t, 1))

%!test
%! % weird SMT order
%! syms x
%! a1 = [27 6];
%! a2 = [6 27];
%! c = coeffs(6*x*x + 27);
%! assert (isequal (c, a1))
%! coeffs(6*x*x + 27);
%! assert (isequal (ans, a1))
%! [c, t] = coeffs(6*x*x + 27);
%! assert (isequal (c, a2))

%!test
%! % no weird order with "all"
%! syms x
%! c = coeffs(6*x*x + 27, 'all');
%! assert (isequal (c, [6 0 27]))

%!test
%! % "all"
%! syms x
%! [c, t] = coeffs(6*x*x + 27, 'all');
%! assert (isequal (c, [6 0 27]))
%! assert (isequal (t, [x^2 x 1]))

%!test
%! % "All"
%! syms x
%! [c, t] = coeffs(6*x, 'All');
%! assert (isequal (c, [6 0]))
%! assert (isequal (t, [x 1]))

%!test
%! % multivariable array
%! syms x y
%! [c, t] = coeffs(6*x*x + 27*y*x  + 36, [x y]);
%! a = [6  27  36];
%! s = [x^2  x*y  1];
%! assert (isequal (c, a))
%! assert (isequal (t, s))
%! % with list
%! [c, t] = coeffs(6*x*x + 27*y*x  + 36, {x y});
%! assert (isequal (c, a))
%! assert (isequal (t, s))

%!test
%! % other symbols treated as part of coeffs
%! syms x y
%! [c, t] = coeffs(6*x*x + 27*y*x  + 36, x);
%! a = [6  27*y  36];
%! s = [x^2  x  1];
%! assert (isequal (c, a))
%! assert (isequal (t, s))

%!error <multivariate polynomials not supported>
%! % TODO: multivariate all not working (https://github.com/cbm755/octsympy/issues/720)
%! syms x y
%! [c, t] = coeffs(6*x^2 + 7*y + 19, [x y], 'all');

%!test
%! % empty same as not specifying; maybe not SMT compatible:
%! % https://github.com/cbm755/octsympy/pull/708#discussion_r94292831
%! syms x y
%! [c, t] = coeffs(6*x*x + 27*y*x  + 36, {});
%! a = [6  27  36];
%! assert (isequal (c, a))
%! [c, t] = coeffs(6*x*x + 27*y*x  + 36);
%! assert (isequal (c, a))

%!test
%! % no input defaults to all symbols (not symvar to get x)
%! syms x y
%! [c, t] = coeffs(6*x*x + 27*y*x  + 36);
%! assert (isequal (c, [6 27 36]))

%!test
%! % non sym input
%! syms x
%! assert (isequal (coeffs(6, x), sym(6)))

%!test
%! % constant input without x
%! assert (isequal (coeffs(sym(6)), sym(6)))

%!test
%! % constant input without x
%! assert (isequal (coeffs (sym(6), {}), sym(6)))

%! % irrational coefficients
%! syms x
%! f = x^2 + sqrt(sym(2))*x;
%! [c1, t1] = coeffs (f);
%! [c2, t2] = coeffs (f, x);
%! assert (isequal (c1, c2))
%! assert (isequal (t1, t2))
