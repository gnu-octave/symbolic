%% Copyright (C) 2014, 2015 Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
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
%% @deftypefn  {Function File} {@var{c} =} coeffs (@var{p}, @var{x})
%% @deftypefnx {Function File} {@var{c} =} coeffs (@var{p})
%% @deftypefnx {Function File} {[@var{c}, @var{t}] =} coeffs (@var{p}, @var{x})
%% @deftypefnx {Function File} {[@var{c}, @var{t}] =} coeffs (@var{p})
%% Return non-zero coefficients of symbolic polynomial.
%%
%% @var{c} contains the coefficients and @var{t} the corresponding
%% terms.
%%
%% Example:
%% @example
%% syms x
%% [c, t] = coeffs (x^6 + 3*x - 4);
%% % gives c = [1 3 -4]
%% %   and t = [x^6 x 1]
%% @end example
%%
%% The polynomial can be multivariate:
%% @example
%% syms x y
%% [c, t] = coeffs (x^2 + y*x);  % c = [1 1], t = [x^2 x*y]
%% [c, t] = coeffs (x^2 + y*x, [x y]);  % same
%% [c, t] = coeffs (x^2 + y*x, @{x y@});  % same
%% @end example
%%
%% You can use the second argument to specify a vector or list of
%% variables:
%% @example
%% [c, t] = coeffs (x^2 + y*x, x);
%% % c = [1 y] and t = [x^2 x]
%% @end example
%%
%% Omitting the second output gives only the coefficients:
%% @example
%% c = coeffs (x^6 + 3*x - 4);   % c = [1 3 -4]
%% @end example
%% WARNING: Matlab's Symbolic Math Toolbox returns c = [-4 3 1]
%% here (as of version 2014a).  I suspect they have a bug as its
%% inconsistent with the rest of Matlab's polynomial routines.  We
%% do not copy this bug.
%%
%% @seealso{sym2poly}
%% @end deftypefn

function [c, t] = coeffs(p, x)

  if ~(isscalar(p))
    error('coeffs: works for scalar input only');
  end

  cmd = { 'f = _ins[0]'
          'xx = _ins[1]'
          'if xx == [] and f.is_constant():'  % special case
          '    xx = sympy.S("x")'
          'try:'
          '    xx = list(xx)'
          'except TypeError:'
          '    xx = [xx]'
          'p = Poly.from_expr(f, *xx)'
          'terms = p.terms()'
          'cc = [q[1] for q in terms]'
          'tt = [1]*len(terms)'
          'for i, x in enumerate(p.gens):'
          '    tt = [t*x**q[0][i] for (t, q) in zip(tt, terms)]'
          'return (Matrix([cc]), Matrix([tt]))' };

  % don't use symvar: if input has x, y we want both
  if (nargin == 1)
    [c, t] = python_cmd (cmd, sym(p), {});
  else
    [c, t] = python_cmd (cmd, sym(p), sym(x));
  end

  %% matlab SMT bug?
  % they seem to reverse the order if t is not output.
  %if (nargout == 1)
  %  c = fliplr(c);
  %end

  % if nargout == 1, here is a simplier implementation:
  %cmd = { 'f = _ins[0]'
  %        'xx = _ins[1]'
  %        'try:'
  %        '    xx = list(xx)'
  %        'except TypeError:'
  %        '    xx = [xx]'
  %        'p = Poly.from_expr(f, *xx)'
  %        'c = p.coeffs()'
  %        'return Matrix([c]),' };

end


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

%%!test
%%! % weird SMT order
%%! syms x
%%! a1 = [27 6];
%%! a2 = [6 27];
%%! c = coeffs(6*x*x + 27);
%%! assert (isequal (c, a1))
%%! [c, t] = coeffs(6*x*x + 27);
%%! assert (isequal (c, a2))

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

%!test
%! % empty same as no specifying
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
