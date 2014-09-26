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
%% @deftypefn  {Function File} {@var{M} =} diag (@var{v})
%% @deftypefnx {Function File} {@var{M} =} diag (@var{v}, @var{k})
%% @deftypefnx {Function File} {@var{M} =} diag (@var{v}, @var{n}, @var{m})
%% @deftypefnx {Function File} {@var{v} =} diag (@var{A})
%% @deftypefnx {Function File} {@var{v} =} diag (@var{A}, @var{k})
%% Make symbolic diagonal matrix or extract diagonal of symbolic matrix.
%%
%% @seealso{repmat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function D = diag(A, k, c)

  if (nargin == 3)
    assert(isvector(A))
  elseif (nargin == 1)
    k = 0;
  end

  if isvector(A)

    if (nargin == 3)
      r = double(k);
      c = double(c);
      k = 0;
    else
      k = double(k);
      r = length(A) + abs(k);
      c = r;
    end

    cmd = { '(A, k, r, c) = _ins'
            'if not A.is_Matrix:'
            '    A = sp.Matrix([A])'
            'D = sp.zeros(r, c)'
            'if k >= 0:'
            '    for i in range(0, min(r, c, c-k, r+k)):'
            '        D[i,i+k] = A[i]'
            'else:'
            '    for i in range(0, min(r, c, c-k, r+k)):'
            '        D[i-k,i] = A[i]'
            'return D,' };

    D = python_cmd (cmd, sym(A), int32(k), int32(r), int32(c));

  else

    cmd = {
      '(A, k) = _ins'
      'if not A.is_Matrix:'
      '    A = sp.Matrix([A])'
      'r, c = A.shape'
      'if k >= 0:'
      '    B = sp.Matrix([A[i,i+k] for i in range(0, min(r, c, c-k, r+k))])'
      'else:'
      '    B = sp.Matrix([A[i-k,i] for i in range(0, min(r, c, c-k, r+k))])'
      'return B,' };

    D = python_cmd (cmd, sym(A), int32(double(k)));

  end
end


%!test
%! % scalar
%! syms x
%! assert (isequal (diag(x), x))

%!test
%! % row,col vec input
%! syms x
%! r = [1 x 2];
%! c = [sym(1); x];
%! assert (isequal (diag(diag(c)), c))
%! assert (isequal (diag(c), [sym(1) 0; 0 x]))
%! assert (isequal (diag(diag(r)), r.'))
%! assert (isequal (diag(r), [sym(1) 0 0; 0 x 0; sym(0) 0 2]))

%!test
%! % create matrix, kth diag
%! syms x
%! r = [1 x];
%! z = sym(0);
%! assert (isequal (diag (x, 0), x))
%! assert (isequal (diag (x, 1), [z x; z z]))
%! assert (isequal (diag (x, -1), [z z; x z]))
%! assert (isequal (diag (x, 2), [z z x; z z z; z z z]))
%! assert (isequal (diag (r, 1), [z 1 z; z z x; z z z]))

%!test
%! % extract kth diag
%! A = sym([1 2 3; 4 5 6]);
%! assert (isequal (diag(A), sym([1; 5])))
%! assert (isequal (diag(A, 0), sym([1; 5])))
%! assert (isequal (diag(A, 1), sym([2; 6])))
%! assert (isequal (diag(A, 2), sym(3)))
%! assert (isequal (diag(A, -1), sym(4)))
%! assert (isempty (diag(A, -2)))
%! assert (isempty (diag(A, 3)))
