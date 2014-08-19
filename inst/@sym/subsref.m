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
%% @deftypefn  {Function File} {@var{out} =} subsref (@var{f}, @var{idx})
%% Access entries of a symbolic array.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function out = subsref (f, idx)

  %disp('call to @sym/subsref')
  switch idx.type
    case '()'
      % sym(sym) indexing in Matlab gets here (on Octave, subsindex
      % does it)
      for i=1:length(idx.subs)
        if (isa(idx.subs{i}, 'sym'))
          idx.subs{i} = subsindex(idx.subs{i})+1;
        end
      end
      out = mat_access(f, idx.subs);

    case '.'
      fld = idx.subs;
      if (strcmp (fld, 'pickle'))
        out = f.pickle;
      elseif (strcmp (fld, 'flat'))
        out = f.flat;
      elseif (strcmp (fld, 'ascii'))
        out = f.ascii;
      elseif (strcmp (fld, 'unicode'))
        out = f.unicode;
      elseif (strcmp (fld, 'extra'))
        out = f.extra;
      % not part of the interface
      %elseif (strcmp (fld, 'size'))
      %  out = f.size;
      else
        error ('@sym/subsref: invalid or nonpublic property ''%s''', fld);
      end

    otherwise
      error ('@sym/subsref: invalid subscript type ''%s''', idx.type);

  end

end

%!shared a,b
%! b = [1:4];
%! a = sym(b);
%!assert(isequal( a(1), b(1) ))
%!assert(isequal( a(2), b(2) ))
%!assert(isequal( a(4), b(4) ))
%!assert(isempty( a([]) ))

%!shared a,b
%! b = [1:4];  b = [b; 3*b; 5*b];
%! a = sym(b);
%!assert(isequal( a(1), b(1) ))
%!assert(isequal( a(2), b(2) ))
%!assert(isequal( a(4), b(4) ))
%!assert(isequal( a(:,:), a ))
%!assert(isequal( a(1:2,1:3), a(1:2,1:3) ))
%!assert(isequal( a(1:2:3,[1 2 4]), b(1:2:3,[1 2 4]) ))
%!assert(isequal( a(1:2:3,[4 2 3 1]), b(1:2:3,[4 2 3 1]) ))
% repeats
%!assert(isequal( a(1:2:3,[4 1 1 1]), b(1:2:3,[4 1 1 1]) ))

%!assert(isequal( a([],:), b([],:) ))
%!assert(isequal( size(a([],:)), [0 4] ))
%!assert(isequal( a(1:2,[]), b(1:2,[]) ))
%!assert(isequal( size(a(1:2,[])), [2 0] ))
%!assert(isempty( a(1:2,[]) ))
%!assert(isempty( a([],[]) ))
%!assert(isequal( a([],[]), sym([]) ))
%!assert(~isequal( a(1:2,[]), sym([]) ))

%!shared e
%! e = sym([1 3 5; 2 4 6]);
%!assert(isequal( e(:), sym((1:6)') ))
%!assert(isequal( e([1 2 3]), sym([1; 2; 3]) ))
%!assert(isequal( e([1; 3; 4]), sym([1; 3; 4]) ))
%!assert(isempty( e([]) ))
%!assert(isequal( e([]), sym([]) ))


%!shared a,b
%! b = 1:5; a = sym(b);
%!assert(isequal(  a([1 2 5]),  b([1 2 5])  ))
%!assert(isequal(  a([1; 2; 5]),  b([1; 2; 5])  ))

%!shared x
%! syms x

%% logical with empty result
%!test
%! assert(isempty( x(false) ))
%! a = [x x];
%! assert(isempty( a([false false]) ))

%% issue 18, scalar access
%!test
%! assert(isequal( x(1), x ))
%! assert(isequal( x(true), x ))


%!test
%! % older access tests
%! syms x
%! f = [x 2; 3 4*x];
%! % element access
%! assert (logical(  f(1,1) == x  ))
%! assert (logical(  f(1,2) == 2  ))
%! % linear access of 2d array
%! assert (logical(  f(1) == x  ))
%! assert (logical(  f(2) == 3  ))  % column based
%! assert (logical(  f(3) == 2  ))

%!shared a,b
%! % effectively a random matrix
%! a = reshape( round(50*(sin(1:20)+1)),  5,4);
%! b = sym(a);

%!test
%! % older array refs test
%! assert (logical(b(1,1) == a(1,1)))
%! assert (logical(b(3,1) == a(3,1)))
%! assert (logical(b(1,3) == a(1,3)))
%! assert (logical(b(4,4) == a(4,4)))

%!test
%! % older array refs test: linear indices
%! assert (logical(b(1) == a(1)))
%! assert (logical(b(3) == a(3)))
%! assert (logical(b(13) == a(13)))

%!test
%! % older array refs test: end
%! assert (all(all(logical(  b(end,1) == a(end,1)  ))))
%! assert (all(all(logical(  b(2,end) == a(2,end)  ))))
%! assert (all(all(logical(  b(end,end) == a(end,end)  ))))
%! assert (all(all(logical(  b(end-1,1) == a(end-1,1)  ))))
%! assert (all(all(logical(  b(2,end-1) == a(2,end-1)  ))))
%! assert (all(all(logical(  b(end-1,end-1) == a(end-1,end-1)  ))))

%!test
%! % older slicing tests
%! syms x
%! a = [1 2 3 4 5 6]; a = [a; 3*a; 5*a; 2*a; 4*a];
%! b = sym(a);
%! assert (isequal(  b(:,1), a(:,1)  ))
%! assert (isequal(  b(:,2), a(:,2)  ))
%! assert (isequal(  b(1,:), a(1,:)  ))
%! assert (isequal(  b(2,:), a(2,:)  ))
%! assert (isequal(  b(:,:), a(:,:)  ))
%! assert (isequal(  b(1:3,2), a(1:3,2)  ))
%! assert (isequal(  b(1:4,:), a(1:4,:)  ))
%! assert (isequal(  b(1:2:5,:), a(1:2:5,:)  ))
%! assert (isequal(  b(1:2:4,:), a(1:2:4,:)  ))
%! assert (isequal(  b(2:2:4,3), a(2:2:4,3)  ))
%! assert (isequal(  b(2:2:4,3), a(2:2:4,3)  ))
