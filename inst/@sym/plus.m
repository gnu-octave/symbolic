%% Copyright (C) 2014, 2016, 2018-2019 Colin B. Macdonald
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
%% @defop  Method   @@sym plus {(@var{x}, @var{y})}
%% @defopx Operator @@sym {@var{x} + @var{y}} {}
%% Add two symbolic expressions together.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% x + y
%%   @result{} (sym) x + y
%% @end group
%% @end example
%% @end defop


function z = plus(x, y)

  % XXX: delete this when we drop support for Octave < 4.4.2
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = plus(x, y);
    return
  end

  % Note elementwise_op *prefers* element-wise operations, which may not
  % be what we always want here (e.g., see MatrixExpr test below).
  %z = elementwise_op ('lambda x, y: x + y', x, y);

  % Instead, we do broadcasting only in special cases (to match
  % Octave behaviour) and otherwise leave it up to SymPy.
  cmd = { 'x, y = _ins'
          'if x is None or y is None:'
          '    return x + y'
          'if x.is_Matrix and not y.is_Matrix:'
          '    return x + y*sp.ones(*x.shape),'
          'if not x.is_Matrix and y.is_Matrix:'
          '    return x*sp.ones(*y.shape) + y,'
          'return x + y' };

  z = pycall_sympy__ (cmd, sym(x), sym(y));

end


%!test
%! % basic addition
%! syms x
%! assert (isa (x+5, 'sym'))
%! assert (isa (5+x, 'sym'))
%! assert (isa (5+sym(4), 'sym'))
%! assert (isequal (5+sym(4), sym(9)))

%!test
%! % array addition
%! syms x
%! D = [0 1; 2 3];
%! A = [sym(0) 1; sym(2) 3];
%! DZ = D - D;
%! assert( isequal ( A + D , 2*D ))
%! assert( isequal ( D + A , 2*D ))
%! assert( isequal ( A + A , 2*D ))
%! assert( isequal ( A + 2 , D + 2 ))
%! assert( isequal ( 4 + A , 4 + D ))

%!test
%! % ensure MatrixExpr can be manipulated somewhat
%! syms n m integer
%! A = sym('A', [n m]);
%! B = subs(A, [n m], [5 6]);
%! B = B + 1;
%! assert (isa (B, 'sym'))
%! C = B(1, 1);  % currently makes a MatrixElement
%! C = C + 1;
%! assert (isa (C, 'sym'))
