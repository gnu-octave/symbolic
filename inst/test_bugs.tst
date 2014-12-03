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



%% Bugs still active
% Change these from xtest to test and move them up as fixed.

%%!test
%%! % FIXME: in SMT, x - true goes to x - 1
%%! syms x
%%! y = x - (1==1)
%%! assert( isequal (y, x - 1))

%!xtest
%! % Issue #8: array construction when row is only doubles
%! % fails on: Octave 3.6.4, 3.8.1, hg tip July 2014.
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

%%!xtest
%%! % this is more serious!
%%! % FIXME: is it? currently goes to false which is reasonable
%%! syms x
%%! e = x - 5 == x - 3;
%%! assert (isa(e, 'sym'))
%%! assert (~isa(e, 'logical'))

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
%! A = sym('A', [n m])
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
%! % FIXME: e.g., cannot add to it
%! B = B + 1
%! assert (isa (B, 'sym'))
