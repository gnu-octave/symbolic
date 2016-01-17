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
%% @deftypefn {Function File}  {@var{r} =} union (@var{A}, @var{B})
%% @deftypefnx {Function File}  {@var{r} =} union (@var{A}, @var{B}, @dots{}, 'intervals')
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

    cmd = {
           'x = _ins'
           '#'
           'if isinstance(x[0], sp.Set):'
           '    t = x[0]'
           'elif not isinstance(x[0], sp.MatrixBase):'
           '    t = Interval(x[0], x[0])'
           'elif len(x[i]) == 1:'
           '    t = Interval(x[0], x[0])'
           'else:'
           '    t = Interval(*x[0])'
           '#'
           'for i in range(1, len(x)):'
           '    if isinstance(x[i], sp.Set):'
           '        t = t.union(x[i])'
           '    elif not isinstance(x[i], sp.MatrixBase):'
           '        t = Interval(x[i], x[i]).union(t)'
           '    elif len(x[i]) == 1:'
           '        t = Interval(x[i], x[i]).union(t)'
           '    else:'
           '        t = Interval(*x[i]).union(t)'
           'return t,'
          };

    r = python_cmd (cmd, varargin{:});
  
  else

    varargin = sym(varargin);

    cmd = {
           'for i in _ins:'
           '    if isinstance(i, sp.Set):'
           '        return 1,'
           'return 0,'
          };

    if python_cmd (cmd, varargin{:});
      r = union(varargin{:}, 'intervals');
      return
    end

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
