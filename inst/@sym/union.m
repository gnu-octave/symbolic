%% Copyright (C) 2016 Colin B. Macdonald and Lagu
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
%% @deftypefn {Function File}  {@var{r} =} setxor (@var{A}, @var{B})
%% Return the union of elements of two sets.
%%
%% @seealso{intersect, setdiff, setxor,function r = intersect(varargin)

function r = union(varargin)

  if strcmp(varargin{nargin}, 'intervals')

    if nargin < 3
      r = varargin;
      return
    end
    
    while (iscell(varargin{1}))
      varargin = varargin{:};
    end

    varargin(nargin)=[];

    varargin = intervals(varargin);

    cmd = {
           'x = _ins'
           't = x[0]'
           'for i in range(1, len(x)):'
           '    t=t.union(x[i])'
           'return t,'
          };

    r = python_cmd (cmd, varargin{:});
  
  else

    % FIXME: is it worth splitting out a "private/set_helper"?

    cmd = { 'A, B = _ins'
            'try:'
            '    A = iter(A)'
            'except TypeError:'
            '    A = set([A])'
            'else:'
            '    A = set(A)'
            'try:'
            '    B = iter(B)'
            'except TypeError:'
            '    B = set([B])'
            'else:'
            '    B = set(B)'
            'C = A.union(B)'
            'C = sympy.Matrix([list(C)])'
            'return C,' };

    varargin = sym(varargin);
    
    r = python_cmd (cmd, varargin{:});

    % reshape to column if both inputs are
    if (iscolumn(varargin{1}) && iscolumn(varargin{2}))
      r = reshape(r, length(r), 1);
    end

  end

end


%!test
%! A = sym([1 2 3]);
%! B = sym([1 2 4]);
%! C = union(A, B);
%! D = sym([1 2 3 4]);
%! assert (isequal (C, D))

%!test
%! % one nonsym
%! A = sym([1 2 3]);
%! B = [1 2 4];
%! C = union(A, B);
%! D = sym([1 2 3 4]);
%! assert (isequal (C, D))

%!test
%! % empty
%! A = sym([1 2 3]);
%! C = union(A, A);
%! assert (isequal(C, A))

%!test
%! % empty input
%! A = sym([1 2]);
%! C = union(A, []);
%! assert (isequal (C, sym([1 2])))


%!test
%! % scalar
%! syms x
%! assert (isequal (union([x 1], x), [1 x]))
%! assert (isequal (union(x, x), x))
