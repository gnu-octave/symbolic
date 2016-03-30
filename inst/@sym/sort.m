%% Copyright (C) 2016 Utkarsh Gautam
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
%% @deftypefn  {Function File} {@var{g} = } sort (@var{f})
%% sort orders the elements in increasing order.
%% @example
%% @group
%% sort([sym(2), sym(1)])
%%   @result{} ans = (sym) [1  2]  (1×2 matrix)
%% @end group
%% @end example
%%
%% For matrices, sort orders the elements within columns
%% @example
%% @group
%% s = sort([sym(2), sym(1); sym(3), sym(0)])
%%   @result{} s = (sym 2×2 matrix)
%%
%%               ⎡2  0⎤
%%               ⎢    ⎥
%%               ⎣3  1⎦
%%
%% @end group
%% @end example
%% @end deftypefn

%% Author: Utkarsh Gautam
%% Keywords: symbolic, sort

function s = sort(f)
  if (rows(f) <=  1 && columns(f) <=  1)
    s = f;
  else
    cmd = {
      '(f) = _ins'
      'f = Matrix(f).tolist()'
      's = []'
      'for c in f:'
      '    s.append(sorted(c))'
      'return Matrix(s)'
      };
    if (rows(f)>1)
      f = f';
      s = python_cmd (cmd, f);
      s = s';
    else
      s = python_cmd (cmd, f);
    end
  end
end

%!test
%! f = [sym(1), sym(0)];
%! expected = sym([0, 1]);
%! assert (isequal (sort(f), expected))

%!test
%! f = [sym(1)];
%! expected = sym(1);
%! assert (isequal (sort(f), expected))

%!test
%! f = [sym(3), sym(2), sym(6)];
%! s = sort(f);
%! expected_s = sym([2, 3, 6]);
%! assert (isequal (s, expected_s))

%!test
%! f = [sym(pi), sin(sym(2)), sqrt(sym(6))];
%! s = sort(f);
%! expected_s = sym([sin(sym(2)), sqrt(sym(6)), sym(pi)]);
%! assert (isequal (s, expected_s))

%!test
%! f = [sym(1), sym(2); sym(2), sym(pi); sym(pi), sym(1)];
%! s = sort(f);
%! expected_s = ([sym(1), sym(1); sym(2), sym(2); sym(pi), sym(pi)]);
%! assert (isequal (s, expected_s))

%!test 
%! assert (isequal (sort(sym([])), sym([])))