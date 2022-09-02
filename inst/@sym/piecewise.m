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
%% @defmethod  @@sym piecewise (@var{cond1}, @var{val1}, @var{cond2}, @var{val2}, @dots{})
%% @defmethodx @@sym piecewise (@var{cond1}, @var{val1}, @var{cond2}, @var{val2}, @dots{}, @var{else_val})
%% Construct piecewise function.
%%
%% The returned piecewise function evaluates to @var{val1} if @var{cond1}
%% holds, @var{val2} if @var{cond2} holds, @dots{} etc.  In the case where none
%% of the conditions hold, it evaluates to @var{else_val} if provided.  If
%% @var{else_val} is not provided, it evaluates to @code{nan}.
%%
%% Examples:
%% @example
%% @group
%% syms x real
%% f = piecewise (abs (x) < 1, exp (- 1 / (1 - x^2)), abs (x) >= 1, 0)
%%   @result{} f = (sym)
%%       ⎧  -1
%%       ⎪ ──────
%%       ⎪      2
%%       ⎨ 1 - x
%%       ⎪ℯ        for │x│ < 1
%%       ⎪
%%       ⎩   0      otherwise
%% @end group
%% @end example
%%
%% For this piecewise function, we can omit the redundant condition at the end:
%% @example
%% @group
%% syms x real
%% f = piecewise (abs (x) < 1, exp (- 1 / (1 - x^2)), 0)
%%   @result{} f = (sym)
%%       ⎧  -1
%%       ⎪ ──────
%%       ⎪      2
%%       ⎨ 1 - x
%%       ⎪ℯ        for │x│ < 1
%%       ⎪
%%       ⎩   0      otherwise
%% @end group
%% @end example
%%
%% @seealso{if}
%% @end defmethod


function f = piecewise (varargin)
  if nargin < 1
    print_usage ();
  end

  cmd = {'def chunks_of(ls, n):'
         '    return itertools.zip_longest(*[ls[k::n] for k in range(n)])'
         'args = [(val, cond) if val is not None else (cond, True)'
         '        for cond, val in chunks_of(_ins, 2)]'
         'return Piecewise(*args)'
        };

  args = cellfun (@sym, varargin, 'UniformOutput', false);
  f = pycall_sympy__ (cmd, args{:});
end


%!test
%! % basic
%! syms x real
%! f = piecewise (abs (x) < 1, 1);
%! assert (isnan (subs (f, -1)));
%! assert (isequal (subs (f, 0), 1));
%! assert (isnan (subs (f, 1)));

%!test
%! % heaviside
%! syms x real
%! f = rewrite (heaviside (x, 1 / sym (2)), 'Piecewise');
%! g = piecewise (x < 0, 0, x == 0, 1 / sym (2), x > 0, 1);
%! assert (logical (simplify (f == g)));

%% FIXME: expand test suite, add SMT compat tests, ...
