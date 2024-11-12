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
%% @defmethod  @@sym iztrans (@var{F}, @var{z}, @var{n})
%% @defmethodx @@sym iztrans (@var{F})
%% @defmethodx @@sym iztrans (@var{F}, @var{n})
%% FIXME: add help text and doctest
%%
%% @seealso{@@sym/ztrans}
%% @end defmethod

%% Author: Alex Vong
%% Keywords: symbolic

function x = iztrans (varargin)
  if (nargin > 3 || nargin == 0)
    print_usage ();
  end

  %% ensure all inputs are sym
  if ~all (cellfun (@(x) isa (x, 'sym'), varargin))
    inputs = cellfun (@sym, varargin, 'UniformOutput', false);
    x = iztrans (inputs{:});
    return
  end

  %% recursively call iztrans for non-scalar inputs
  if ~all (cellfun (@isscalar, varargin))
    inputs = cellfun (@(x) num2cell (x), varargin, 'UniformOutput', false);
    x = sym (cellfun (@iztrans, inputs{:}, 'UniformOutput', false));
    return
  end

  F = sym (varargin{1});
  F_vars = findsymbols (F);
  find_var_from_F = @(v) F_vars (cellfun (@(x) strcmp (char (x), v), F_vars));

  %% select var z
  if (nargin == 3)
    z = sym (varargin{2});
  else
    zs = find_var_from_F ('z');
    assert (numel (zs) <= 1, 'ztrans: there is more than one "z" symbol: check symvar (F) and sympy (F)');
    if (~isempty (zs))
      z = zs{:}; % use var z from F
    elseif (~isempty (F_vars))
      z = symvar (F, 1); % select var from F using symfun
    else
      z = sym ('z'); % use freshly generated var z, FIXME: any assumptions?
    end
  end

  %% select var n
  if (nargin == 3)
    n = sym (varargin{3});
  elseif (nargin == 2)
    n = sym (varargin{2});
  else
    ns = find_var_from_F ('n');
    if (isempty (ns)) % use var n if F is a not function of n
      n = sym ('n');
    else % use var k if F is a function of n
      n = sym ('k');
    end
  end

  cmd = {'from sympy.series.formal import compute_fps'
         'def unevaluated_iztrans(F, z, n):'
         '    R = Symbol("R", positive=True, real=True)'
         '    theta = Symbol("theta", real=True)'
         '    F_polar = F.subs(z, R * exp(I * theta))'
         '    xn = Limit(R**n * Integral(F_polar * exp(I * n * theta),'
         '                               (theta, -pi, pi)),'
         '               R, +oo) / (2 * pi)'
         '    return xn'
         'def poly_to_lin_comb_of_kron_delta(p):'
         '    return sum([ak * KroneckerDelta(n - k, 0)'
         '                for ((k,), ak) in p.all_terms()])'
         '(F, z, n) = _ins'
         'F_of_1_over_z = F.subs(z, 1 / z)'
         'if expand(F_of_1_over_z).is_polynomial(z):'
         '    return poly_to_lin_comb_of_kron_delta(F_of_1_over_z.as_poly(z))'
         'try:'
         '    (ak, _, ind) = compute_fps(F_of_1_over_z, z)'
         'except TypeError:'
         '    return unevaluated_iztrans(F, z, n)'
         '(k,) = ak.variables'
         'assert ak.start.is_integer and ak.start >= 0 and ak.stop == +oo'
         'if expand(ind).is_polynomial(z):'
         '    an = Piecewise((ak.formula.subs(k, n), n >= ak.start), (0, True))'
         '    bn = poly_to_lin_comb_of_kron_delta(ind.as_poly(z))'
         '    xn = piecewise_fold(an) + bn'
         '    return xn'
         'else:'
         '    return unevaluated_iztrans(F, z, n)'};
  x = pycall_sympy__ (cmd, F, z, n);
end

%% FIXME: add bist
