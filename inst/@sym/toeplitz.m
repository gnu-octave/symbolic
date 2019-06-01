%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym toeplitz (@var{c}, @var{r})
%% @defmethodx @@sym toeplitz (@var{r})
%% Construct a symbolic Toeplitz matrix.
%%
%% Examples:
%% @example
%% @group
%% A = toeplitz (sym([0 1 2 3]))
%%   @result{} A = (sym 4×4 matrix)
%%
%%       ⎡0  1  2  3⎤
%%       ⎢          ⎥
%%       ⎢1  0  1  2⎥
%%       ⎢          ⎥
%%       ⎢2  1  0  1⎥
%%       ⎢          ⎥
%%       ⎣3  2  1  0⎦
%%
%% A = toeplitz (sym([0 1 2 3]), sym([0 -1 -2 -3 -4]))
%%   @result{} A = (sym 4×5 matrix)
%%
%%       ⎡0  -1  -2  -3  -4⎤
%%       ⎢                 ⎥
%%       ⎢1  0   -1  -2  -3⎥
%%       ⎢                 ⎥
%%       ⎢2  1   0   -1  -2⎥
%%       ⎢                 ⎥
%%       ⎣3  2   1   0   -1⎦
%% @end group
%% @end example
%%
%% @end defmethod


function A = toeplitz (C, R)

  if (nargin == 1)
    [C, R] = deal(C', C);
  elseif (nargin ~= 2)
    print_usage ();
  end

  R = sym(R);
  C = sym(C);

  assert(isvector(R));
  assert(isvector(C));

  % Diagonal conflict
  idx.type = '()';  idx.subs = {1};
  if (nargin == 2) && ~(isequal(subsref(R,idx), subsref(C,idx)));
    warning('OctSymPy:toeplitz:diagconflict', ...
            'toeplitz: column wins diagonal conflict')
    R = subsasgn(R, idx, subsref(C, idx));
  end
  % (if just one input (R) then we want it to get the diag)


  cmd = { '(C, R) = _ins'
          'if not R.is_Matrix:'
          '    return R'
          '(n, m) = (len(C), len(R))'
          'A = sp.zeros(n, m)'
          'for i in range(0, n):'
          '    for j in range(0, m):'
          '        if i - j > 0:'
          '            A[i, j] = C[i-j]'
          '        else:'
          '            A[i, j] = R[j-i]'
          'return A' };

  A = pycall_sympy__ (cmd, C, R);

end


%!test
%! % rect
%! R = [10 20 40];  C = [10 30];
%! A = sym(toeplitz(R,C));
%! B = toeplitz(sym(R),sym(C));
%! assert (isequal (A, B))
%! R = [10 20];  C = [10 30 50];
%! A = sym(toeplitz(R,C));
%! B = toeplitz(sym(R),sym(C));
%! assert (isequal (A, B))

%!test
%! % symbols
%! syms x y
%! R = [10 20 40];  C = [10 30];
%! Rs = [10 x 40];  Cs = [10 y];
%! A = toeplitz(R,C);
%! B = toeplitz(Rs,Cs);
%! assert (isequal (A, subs(B,[x,y],[20 30])))

%!test
%! % hermitian
%! syms a b c
%! A = [a b c; conj(b) a b; conj(c) conj(b) a];
%! B = toeplitz([a,b,c]);
%! assert (isequal( A, B))

%!warning <diagonal conflict>
%! % mismatch
%! syms x
%! B = toeplitz([10 x], [1 3 x]);

%!warning <diagonal conflict>
%! % scalar
%! B = toeplitz(sym(2), 3);
%! assert (isequal (B, sym(2)))

%!test
%! % mismatch
%! syms x y
%! fprintf('\n  one warning expected\n')  % how to quiet this one?
%! A = toeplitz([10 2], [1 3 5]);
%! s = warning ('off', 'OctSymPy:toeplitz:diagconflict');
%! B = toeplitz([10 x], [1 3 y]);
%! warning(s)
%! assert (isequal (A, subs(B, [x,y], [2 5])))
