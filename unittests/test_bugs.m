function r = test_bugs()
  c = 0; r = [];
  syms x

  warning('todo known failures to fix')

  D = [0 1; 2 3];

  %% array construction: this works
  A = [sym(0) 1; sym(2) 3];
  c=c+1; r(c) = true;

  %% but this fails
  try
    A = [sym(0) 1; 2 3];
    c=c+1; r(c) = true;
  catch
    c=c+1; r(c) = false;
  end

  %% size issues
  c=c+1; r(c) = all(  size(any(A-D)) == [1 2]  )
  c=c+1; r(c) = all(  size(double(A)) == size(A)  )


  DZ = D - D;


  %% todo: need symzeros cmd
  %c=c+1; r(c) = all(all(logical(  D - A == DZ  )));

