%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{A} =} toeplitz (@var{c}, @var{r})
%% @deftypefnx {Function File} {@var{A} =} toeplitz (@var{r})
%% Construct a symbolic Toeplitz matrix.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function A = toeplitz(C,R)

  if (nargin == 1)
    [C,R] = deal(C',C);
  end

  if ~(isa(R, 'sym'))
    R = sym(R);
  end

  if ~(isa(C, 'sym'))
    C = sym(C);
  end

  assert(isvector(R));
  assert(isvector(C));

  % Diagonal conflict
  idx.type = '()';  idx.subs = {1};
  if (nargin == 2) && ~(isequal(subsref(R,idx), subsref(C,idx)));
    warning('toeplitz: column wins diagonal conflict')
    R = subsasgn(R, idx, subsref(C, idx));
  end
  % (if just one input (R) then we want it to get the diag)


  cmd = [ '(C,R) = _ins\n'  ...
          'if not R.is_Matrix:\n' ...
          '    return ( R[0] ,)\n' ...
          '(n,m) = (len(C),len(R))\n' ...
          'A = sp.zeros(n,m)\n' ...
          'for i in range(0,n):\n' ...
          '    for j in range(0,m):\n' ...
          '        if i-j > 0:\n' ...
          '            A[i,j] = C[i-j]\n' ...
          '        else:\n' ...
          '            A[i,j] = R[j-i]\n' ...
          'return ( A ,)\n' ...
           ];

  A = python_cmd (cmd, C, R);

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

%!test
%! % mismatch
%! syms x y
%! fprintf('\n*** Two warning expected ***\n')
%! A = toeplitz([10 2], [1 3 5]);
%! B = toeplitz([10 x], [1 3 y]);
%! assert (isequal (A, subs(B,[x,y],[2 5])))
