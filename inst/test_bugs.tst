%% Copyright (C) 2014-2017 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
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

%% Tests
% tests listed here are for current or fixed bugs.  Could move
% these to appropriate functions later if desired.

%!test
%! % Issue #5, scalar expansion
%! a = sym(1);
%! a(2) = 2;
%! assert (isequal(a, [1 2]))
%! a = sym([]);
%! a([1 2]) = [1 2];
%! assert (isa(a, 'sym'))
%! assert (isequal(a, [1 2]))
%! a = sym([]);
%! a([1 2]) = sym([1 2]);
%! assert (isa(a, 'sym'))
%! assert (isequal(a, [1 2]))


%!test
%! % "any, all" not implemented
%! D = [0 1; 2 3];
%! A = sym(D);
%! assert (isequal( size(any(A-D)), [1 2] ))
%! assert (isequal( size(all(A-D,2)), [2 1] ))


%!test
%! % double wasn't implemented correctly for arrays
%! D = [0 1; 2 3];
%! A = sym(D);
%! assert (isequal( size(double(A)), size(A) ))
%! assert (isequal( double(A), D ))


%!test
%! % in the past, inf/nan in array ctor made wrong matrix
%! a = sym([nan 1 2]);
%! assert (isequaln (a, [nan 1 2]))
%! a = sym([1 inf]);
%! assert( isequaln (a, [1 inf]))

%!test
%! % Issue #103: rot90, fliplr, flipud, flip on scalars
%! % (In Octave, we do not need to overload these)
%! syms x
%! assert (isequal (rot90(x), x))
%! assert (isequal (rot90(x, 1), x))
%! assert (isequal (rot90(x, 17), x))
%! assert (isequal (fliplr(x), x))
%! assert (isequal (flipud(x), x))

%!test
%! % Issue #103: rot90, fliplr, flipud, flip on vectors
%! syms x
%! h = [1 2 x];
%! v = [1; 2; x];
%! assert (isequal (rot90(h), flipud(v)))
%! assert (isequal (rot90(h, 1), flipud(v)))
%! assert (isequal (rot90(h, 2), fliplr(h)))
%! assert (isequal (rot90(h, 3), v))
%! assert (isequal (rot90(h, 4), h))
%! assert (isequal (rot90(h, 17), rot90(h, 1)))
%! assert (isequal (rot90(v), h))
%! assert (isequal (flipud(h), h))
%! assert (isequal (fliplr(v), v))
%! assert (isequal (fliplr(h), [x 2 1]))
%! assert (isequal (flipud(v), [x; 2; 1]))

%!test
%! % Issue #103: rot90, fliplr, flipud, flip on matrices
%! syms x
%! A = [1 x 3; x 5 6];
%! assert (isequal (rot90(A), [sym(3) 6; x 5; 1 x]))
%! assert (isequal (rot90(A, 2), [6 5 x; 3 x 1]))
%! assert (isequal (rot90(A, 3), [x 1; 5 x; sym(6) 3]))
%! assert (isequal (rot90(A, 4), A))
%! assert (isequal (flipud(A), [x 5 6; 1 x 3]))
%! assert (isequal (fliplr(A), [3 x 1; 6 5 x]))

%!test
%! syms x
%! h = [1 2 x];
%! v = [1; 2; x];
%! A = [1 x 3; x 5 6];
%! assert (isequal (flip(x), x))
%! assert (isequal (flip(x, 1), x))
%! assert (isequal (flip(x, 2), x))
%! assert (isequal (flip(h, 1), h))
%! assert (isequal (flip(h, 2), fliplr(h)))
%! assert (isequal (flip(A, 1), flipud(A)))
%! assert (isequal (flip(A, 2), fliplr(A)))


%% Bugs still active
% Change these from xtest to test and move them up as fixed.

%%!test
%%! % FIXME: in SMT, x - true goes to x - 1
%%! syms x
%%! y = x - (1==1)
%%! assert( isequal (y, x - 1))

%!xtest
%! % Issue #8: array construction when row is only doubles
%! % fails on: Octave 3.6.4, 3.8.1, 4.0.0, hg tip Dec 2015.
%! % works on: Matlab
%! try
%!   A = [sym(0) 1; 2 3];
%!   failed = false;
%! catch
%!   failed = true;
%! end
%! assert (~failed)
%! assert (isequal(A, [1 2; 3 4]))


%!test
%! % boolean not converted to sym (part of Issue #58)
%! y = sym(1==1);
%! assert( isa (y, 'sym'))
%! y = sym(1==0);
%! assert( isa (y, 'sym'))


%!test
%! % Issue #9, nan == 1 should be bool false not "nan == 1" sym
%! snan = sym(0)/0;
%! y = snan == 1;
%! assert (~logical(y))

%!test
%! % Issue #9, for arrays, passes currently, probably for wrong reason
%! snan = sym(nan);
%! A = [snan snan 1] == [10 12 1];
%! assert (isequal (A, sym([false false true])))

%!test
%! % these seem to work
%! e = sym(inf) == 1;
%! assert (~logical(e))


%!test
%! % known failure, issue #55; an upstream issue
%! snan = sym(nan);
%! assert (~logical(snan == snan))




%% x == x tests
% Probably should move to eq.m when fixed

%!test
%! % in SMT x == x is a sym (not "true") and isAlways returns true
%! syms x
%! assert (isAlways(  x == x  ))

%!xtest
%! % fails to match SMT (although true here is certainly reasonable)
%! syms x
%! e = x == x;
%! assert (strcmp (strtrim(disp(e, 'flat')), 'x == x'))

%!xtest
%! % "fails" (well goes to false, which is reasonable enough)
%! syms x
%! e = x - 5 == x - 3;
%! assert (strcmp (strtrim(disp(e, 'flat')), 'x - 5 == x - 3'))

%%!test
%%! % using eq for == and "same obj" is strange, part 1
%%! % this case passes
%%! syms x
%%! e = (x == 4) == (x == 4);
%%! assert (isAlways( e ))
%%! assert (logical( e ))

%%!test
%%! % using eq for == and "same obj" is strange, part 2
%%! syms x
%%! e = (x-5 == x-3) == (x == 4);
%%! assert (~logical( e ))
%%! % assert (~isAlways( e ))

%%!xtest
%%! % using eq for == and "same obj" is strange, part 3
%%! % this fails too, but should be true, although perhaps
%%! % only with a call to simplify (i.e., isAlways should
%%! % get it right).
%%! syms x
%%! e = (2*x-5 == x-1) == (x == 4);
%%! assert (isAlways( e ))
%%! assert (islogical( e ))
%%! assert (isa(e, 'logical'))
%%! assert (e)

%!xtest
%! % SMT behaviour for arrays: if any x's it should not be logical
%! % output but instead syms for the equality objects
%! syms x
%! assert (isequal ( [x x] == sym([1 2]), [x==1 x==2] ))
%! assert (isequal ( [x x] == [1 2], [x==1 x==2] ))
%! % FIXME: new bool means these don't test the right thing
%! %assert (~islogical( [x 1] == 1 ))
%! %assert (~islogical( [x 1] == x ))
%! %assert (~islogical( [x x] == x ))  % not so clear

%!xtest
%! % FIXME: symbolic matrix size, Issue #159
%! syms n m integer
%! A = sym('A', [n m]);
%! assert (isequal (size (A), [n m]))

%!xtest
%! % symbolic matrix, subs in for size, Issue #160
%! syms n m integer
%! A = sym('A', [n m]);
%! B = subs(A, [n m], [5 6]);
%! assert (isa (B, 'sym'))
%! assert (isequal (size (B), [5 6]))
%! % FIXME: not same as an freshly created 5 x 6.
%! C = sym('B', [5 6]);
%! assert (isequal(B, C))
