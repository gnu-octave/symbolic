%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{z} =} mat_rclist_asgn (@var{A}, @var{r}, @var{c}, @var{B})
%% Private helper routine for sym array assigment using lists.
%%
%% @code{(R(i),C(i))} specify entries of the matrix @var{A}.
%% We execute @code{A(R(i),C(i)) = B(i)}.
%%
%% Notes:
%% @itemize
%% @item  @var{B} is accessed with linear indexing.
%% @item  @var{B} might be a scalar, used many times.
%% @item  @var{A} might need to get bigger, if so it will be padded
%%        with zeros.
%% @end itemize
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mat_rclist_asgn(A, r, c, B)

  if ~( isvector(r) && isvector(c) && (length(r) == length(c)) )
    error('this routine is for a list of rows and cols');
  end

  if ((numel(B) == 1) && (numel(r) > 1))
    % B should be a sym unless experimenting with various bool
    % trickery.
    % FIXME: Issue #71: why does this work even if B is sym w/ bools?
    B = B*ones(size(r));
    % If sym, we probably can't use repmat (recursion?).
    %if isa(B, 'sym')
    %  B = B*ones(size(r));
    %else
    %  warning('activating repmat code: a non-sym snuck in?')
    %  assert( islogical (B))
    %  B = repmat(B, size(r));
    %end
  end
  if (length(r) ~= numel(B))
    error('not enough/too much in B')
  end

  % Note: we expand by making a new big enough matrix and calling
  % .copyin_matrix.  Easiest as: new[0,0] = old

  cmd = { '(A, r, c, B) = _ins'
          '# B linear access fix, transpose for sympy row-based'
          'if B is None or not B.is_Matrix:'
          '    B = sp.Matrix([[B]])'
          'BT = B.T'
          '# copy of A, expanded and padded with zeros'
          'if not A.is_Matrix:'
          '    n = max( max(r)+1, 1 )'
          '    m = max( max(c)+1, 1 )'
          'else:'
          '    n = max( max(r)+1, A.rows )'
          '    m = max( max(c)+1, A.cols )'
          'AA = sp.Matrix.zeros(n, m)'
          'AA[0, 0] = A'
          'for i in range(0, len(r)):'
          '    AA[r[i],c[i]] = BT[i]'
          'return AA,' };

  rr = num2cell(int32(r-1));
  cc = num2cell(int32(c-1));
  z = python_cmd (cmd, A, rr, cc, B);

  % a simpler earlier version, but only for scalar r,c
  %cmd = { '(A, r, c, b) = _ins'
  %        'if not A.is_Matrix:'
  %        '    A = sp.Matrix([[A]])'
  %        'AA = sp.Matrix.zeros(max(r+1, A.rows), max(c+1, A.cols))'
  %        'AA[0, 0] = A'
  %        'AA[r, c] = b'
  %        'return AA,' };
end


%% Note: tests in @sym/private/ not executed
% To run these in the test suite, you could move this mfile up to @sym.
% However, note these are generally tested elsewhere indirectly.

%!shared A, B
%! B = [1 2 3; 4 5 6];
%! A = sym(B);
%!test
%! C = B; C([1 6]) = [8 9];
%! assert (isequal (mat_rclist_asgn(A,[1 2],[1 3],sym([8 9])), C))

%!test
%! % rhs scalar
%! C = B; C([1 6]) = 88;
%! assert (isequal (mat_rclist_asgn(A,[1 2],[1 3],sym(88)), C))

%!test
%! % If rhs is not a vector, make sure col-based access works
%! rhs = [18 20; 19 21];
%! C = B; C([1 2 3 4]) = rhs;
%! D = mat_rclist_asgn(A,[1 2 1 2],[1 1 2 2],sym(rhs));
%! assert (isequal (D, C))

%!test
%! % Growth
%! C = B; C(1,5) = 10;
%! D = mat_rclist_asgn(A,1,5,sym(10));
%! assert (isequal (D, C))
