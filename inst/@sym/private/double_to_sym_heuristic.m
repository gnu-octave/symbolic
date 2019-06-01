%% Copyright (C) 2017, 2019 Colin B. Macdonald
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
%% @deftypefun {@var{y} =} double_to_sym_heuristic (@var{x}, @var{ratwarn}, @var{argnstr})
%% Convert a double value to a nearby "nice" sym
%%
%% Private helper function.
%%
%% @end deftypefun

function y = double_to_sym_heuristic (x, ratwarn, argnstr)
  assert (isempty (argnstr))
  if (isnan (x))
    y = pycall_sympy__ ('return S.NaN');
  elseif (isinf (x) && x < 0)
    y = pycall_sympy__ ('return -S.Infinity');
  elseif (isinf (x))
    y = pycall_sympy__ ('return S.Infinity');
  elseif (isequal (x, pi))
    %% Special case for pi
    y = pycall_sympy__ ('return S.Pi');
  elseif (isequal (x, -pi))
    y = pycall_sympy__ ('return -S.Pi');
  elseif (isequal (x, exp (1)))
    %% Special case for e
    y = pycall_sympy__ ('return sympy.exp(1)');
  elseif (isequal (x, -exp (1)))
    y = pycall_sympy__ ('return -sympy.exp(1)');
  elseif ((abs (x) < flintmax) && (mod (x, 1) == 0))
    y = pycall_sympy__ ('return Integer(_ins[0])', int64 (x));
  else
    %% Find the nearest rational, rational*pi or sqrt(integer)
    if (ratwarn)
      warning('OctSymPy:sym:rationalapprox', ...
              'passing floating-point values to sym is dangerous, see "help sym"');
    end
    [N1, D1] = rat (x);
    [N2, D2] = rat (x / pi);
    N3 = round (x^2);
    err1 = abs (N1 / D1 - x);
    err2 = abs ((N2*pi) / D2 - x);
    err3 = abs (sqrt (N3) - x);
    if (err1 <= err3)
      if (err1 <= err2)
        y = pycall_sympy__ ('return Rational(*_ins)', int64 (N1), int64 (D1));
      else
        y = pycall_sympy__ ('return Rational(*_ins)*S.Pi', int64 (N2), int64 (D2));
      end
    else
      y = pycall_sympy__ ('return sqrt(Integer(*_ins))', int64 (N3));
    end
  end
end
