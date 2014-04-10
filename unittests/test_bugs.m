function r = test_bugs()
  c = 0; r = [];
  syms x

  % Issue #5, scalar expansion
  a = sym(1);
  a(2) = 2;
  c=c+1; r(c) = isequal(a, [1 2]);



  warning('todo known failures to fix')


  D = [0 1; 2 3];

  %% array construction: this works
  A = [sym(0) 1; sym(2) 3];
  c=c+1; r(c) = all(all( A == D ));

  %% but this fails
  %try
  %  A = [sym(0) 1; 2 3];
  %  c=c+1; r(c) = true;
  %catch
  %  c=c+1; r(c) = false;
  %end
  c=c+1; r(c) = false;


  %% size issues, any and double not implemented
  %c=c+1; r(c) = all(  size(any(A-D)) == [1 2]  )
  %c=c+1; r(c) = all(  size(double(A)) == size(A)  )
  c=c+1; r(c) = false;
  c=c+1; r(c) = false;


  DZ = D - D;



  % todo: bug? boolean not converted to sym
  c=c+1; r(c) = 0;
  %sym(1==1)
  %sym(1==0)
  %x - (1==1)
  %x - (1==0)

  % bug!  inf/nan in array ctor makes wrong matrix
  a = sym([nan 1 2]);
  c=c+1;  r(c) = isequaln(  a, [nan 1 2]  );
  a = sym([1 inf]);
  c=c+1;  r(c) = isequaln(  a, [1 inf]  );
