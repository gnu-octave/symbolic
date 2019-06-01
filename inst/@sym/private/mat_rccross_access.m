%% Copyright (C) 2014, 2019 Colin B. Macdonald
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
%% @defun mat_rccross_access (@var{A}, @var{r}, @var{c})
%% Private helper routine for symbolic array access.
%%
%% Access entries of @var{A} that are the cross product of vectors
%% @var{r} and @var{c}.  @var{r} and @var{c} could be strings.
%% Namely @code{':'}.
%%
%% @var{r} and @var{c} could contain duplicates.  This is one
%% reason by this code doesn't easily replace
%% @code{mat_rclist_access}.
%%
%% @end defun


function z = mat_rccross_access(A, r, c)

  if (ischar(r) && ischar(c) && strcmp(r, ':') && strcmp(c, ':'))
    z = A;
    return
  end

  %if both expressible as py slices...
  % FIXME: Could optimize these cases

  [n, m] = size(A);

  if (isnumeric(r) && isempty(r))
    % no-op
  elseif (isnumeric(r) && isvector(r))
    assert(all(r >= 1) && all(r <= n), 'index out of range')
  elseif (strcmp(r, ':'))
    r = 1:n;
  elseif (islogical(r) && isvector(r) && (length(r) == n))
    I = r;
    r = 1:n;  r = r(I);
  else
    error('unknown 2d-indexing in rows')
  end

  if (isnumeric(c) && isempty(c))
    % no-op
  elseif (isnumeric(c) && isvector(c))
    assert(all(c >= 1) && all(c <= m), 'index out of range')
  elseif (strcmp(c,':'))
    c = 1:m;
  elseif (islogical(c) && isvector(c) && (length(c) == m))
    J = c;
    c = 1:m;  c = c(J);
  else
    error('unknown 2d-indexing in columns')
  end

  cmd = { '(A, rr, cc) = _ins'
          'if not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'M = sp.Matrix.zeros(len(rr), len(cc))'
          'for i in range(0, len(rr)):'
          '    for j in range(0, len(cc)):'
          '        M[i,j] = A[rr[i], cc[j]]'
          'return M,' };

  rr = num2cell(int32(r-1));
  cc = num2cell(int32(c-1));
  z = pycall_sympy__ (cmd, A, rr, cc);

  % FIXME: here's some code could be used for slices
  if (1==0)
  cmd = { 'A = _ins[0]'  ...
          'r = slice(_ins[1],_ins[2])'  ...
          'c = slice(_ins[3],_ins[4])'  ...
          'M = A[r,c]'  ...
          'return M,' };
  z = pycall_sympy__ (cmd, A, r1-1, r2, c1-1, c2);
  end
end
