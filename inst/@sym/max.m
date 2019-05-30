%% Copyright (C) 2015, 2016, 2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} max (@var{a})
%% @deftypemethodx @@sym {} max (@var{a}, @var{b})
%% @deftypemethodx @@sym {} max (@var{a}, [], @var{dim})
%% @deftypemethodx @@sym {[@var{r}, @var{I}] =} max (@dots{})
%% Return maximum value of a symbolic vector or vectors.
%%
%% Example:
%% @example
%% @group
%% max(sym(1), sym(2))
%%   @result{} (sym) 2
%% max([1 2*sym(pi) 6])
%%   @result{} (sym) 2⋅π
%% [M, I] = max([1 2*sym(pi) 6])
%%   @result{} M = (sym) 2⋅π
%%   @result{} I = 2
%% @end group
%% @end example
%%
%% @seealso{@@sym/min}
%% @end deftypemethod


function [z, I] = max(A, B, dim)

  if (nargout <= 1)
    if (nargin == 1)
      if (isvector(A))
        z = pycall_sympy__ ('return Max(*_ins[0])', A);
      else
        z = max(A, [], 1);
      end
    elseif (nargin == 2)
      z = elementwise_op ('Max', sym(A), sym(B));
    elseif (nargin == 3)
      assert (isempty (B))
      assert (logical(dim == 1) || logical(dim == 2))

      cmd = { '(A, dim) = _ins'
              'if not A.is_Matrix:'
              '    A = sp.Matrix([A])'
              'if dim == 0:'
              '    if A.rows == 0:'
              '        return A'
              '    return Matrix([[Max(*A.col(i)) for i in range(0, A.cols)]])'
              'elif dim == 1:'
              '    if A.cols == 0:'
              '        return A'
              '    return Matrix([Max(*A.row(i)) for i in range(0, A.rows)])' };
      z = pycall_sympy__ (cmd, A, dim - 1);
    else
      print_usage ();
    end
    return
  end

  % dealing with the index (2nd output) is complicated, defer to min
  if (nargin == 1)
    [z, I] = min(-A);
    z = -z;
  elseif (nargin == 3)
    [z, I] = min(-A, -B, dim);
    z = -z;
  else
    print_usage ();
  end

end


%% many other tests are in @sym/min

%!test
%! % simple
%! assert (isequal (max([sym(10) sym(11)]), sym(11)))

%!test
%! syms x y
%! assert (isequal (children (max (x, y)), [x y]))
