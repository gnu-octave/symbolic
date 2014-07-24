% count = 1
dirs = {'.' '@symfun' '@logical' '@sym'};

if ~exist('count') || count == 0

  for j = 1:length(dirs)
    runtests(fullfile(pwd, dirs{j}))
    fprintf('%s\n\n', char('_'*ones(1,80)));
  end

else

  %% Old version
  % keeping this code around b/c it can count the number of tests
  % passed for me...

  totaltime = clock();
  totalcputime = cputime();

  num_tests = 0;
  num_passed = 0;

  for j = 1:length(dirs)
    %methods_list = methods(classes{j});
    %base = ['@' classes{j}];
    thisdir = fullfile(pwd, dirs{j});
    files = dir(thisdir);

    %for i=1:length(methods_list)
    %m = methods_list{i};
    for i=1:length(files)
      m = files(i).name;
      if ( (~files(i).isdir) && strcmp(m(end-1:end), '.m') )
        [N,MAX] = test([dirs{j} '/' m], [], stdout);
        num_tests = num_tests + MAX;
        num_passed = num_passed + N;
        if (MAX > 0)
          fprintf('        Passed %d of %d\n', N, MAX);
          %fprintf('%s\n\n', char('_'*ones(1,80)));
          %fprintf('  (paused)\n'); pause
        end
      end
    end
  end
  totaltime = etime(clock(), totaltime);
  totalcputime = cputime() - totalcputime;
  fprintf('\n***** Passed %d/%d tests passed, %g seconds (%gs CPU) *****\n', ...
          num_passed, num_tests, totaltime, totalcputime);
  if (num_tests - num_passed > 0)
    disp('***** WARNING: some tests failed *****');
  end
end


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



%!xtest
%! % boolean not converted to sym (part of Issue #58)
%! y = sym(1==1);
%! assert( isa (y, 'sym'))
%! y = sym(1==0);
%! assert( isa (y, 'sym'))
%! % what should this mean?
%! %syms x
%! %y = x - (1==1)
%! %assert( isa (y, 'sym'))


%!xtest
%! % Issue #9, nan == 1 should be bool false not "nan == 1" sym
%! snan = sym(0)/0;
%! y = snan == 1;
%! assert (islogical(y))
%! assert (~isa(y, 'sym'))
%!test
%! % Issue #9, for arrays, passes currently, probably for wrong reason
%! snan = sym(nan);
%! A = [snan snan 1] == [10 12 1];
%! assert (islogical (A))
%! assert (isequal (A, [false false true]))
%!test
%! % these seem to work
%! assert (islogical(sym(inf) == 1))
%! assert ((sym(inf) == 1) == false)


%!xtest
%! % known failure, issue #55; an upstream issue
%! snan = sym(nan);
%! assert(~(snan == snan))


%% ops with inf
% move to isinf once fixed?

%!xtest
%! % ops with infinity don't collapse
%! syms x oo zoo
%! y = x+oo;
%! assert(~isempty( strfind(lower(y.pickle), 'add') ))
%! y = x-oo;
%! assert(~isempty( strfind(lower(y.pickle), 'add') ))
%! y = x-zoo;
%! assert(~isempty( strfind(lower(y.pickle), 'add') ))
%! y = x*oo;
%! assert(~isempty( strfind(lower(y.pickle), 'mul') ))

%!xtest
%! % KNOWN FAILURE, x + oo
%! % isinf(x + oo)?  SMT 2014a says "true"
%! syms x oo zoo
%! y = x+oo;
%! assert(isinf(y))
%! y = x-zoo;
%! assert(isinf(y))
%! y = x*oo;
%! assert(isinf(y))



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
%! assert (isa(e, 'sym'))
%! assert (~isa(e, 'logical'))

%!xtest
%! % this is more serious!
%! syms x
%! e = x - 5 == x - 3;
%! assert (isa(e, 'sym'))
%! assert (~isa(e, 'logical'))

%!test
%! % using eq for == and "same obj" is strange, part 1
%! % this case passes
%! syms x
%! e = (x == 4) == (x == 4);
%! assert (isAlways( e ))
%! assert (islogical( e ))
%! assert (isa(e, 'logical'))
%! assert (e)

%!xtest
%! % using eq for == and "same obj" is strange, part 2
%! % this fails, but should be false
%! syms x
%! e = (x-5 == x-3) == (x == 4);
%! assert (isAlways( e ))
%! assert (islogical( e ))
%! assert (isa(e, 'logical'))
%! assert (~e)

%!xtest
%! % using eq for == and "same obj" is strange, part 3
%! % this fails too, but should be true, although perhaps
%! % only with a call to simplify (i.e., isAlways should
%! % get it right).
%! syms x
%! e = (2*x-5 == x-1) == (x == 4);
%! assert (isAlways( e ))
%! assert (islogical( e ))
%! assert (isa(e, 'logical'))
%! assert (e)

%!xtest
%! % SMT behaviour for arrays: if any x's it should not be logical
%! % output but instead syms for the equality objects
%! syms x
%! assert (~islogical( [x 1] == 1 ))
%! assert (~islogical( [x 1] == x ))
%! assert (~islogical( [x x] == x ))  % not so clear
%! assert (isequal( [x x] == sym([1 2]), [x==1 x==2] ))
%! assert (isequal( [x x] == [1 2], [x==1 x==2] ))
