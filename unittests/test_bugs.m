function r = test_bugs()
  c = 0; r = [];
  syms x



  %% Issue #8
  % array construction when row is only doubles
  % fails on: Octave 3.6.4 *and* 3.8.1
  % works on: Matlab
  try
    %A = [sym(0) 1; sym(2) 3];  % this works
    A = [sym(0) 1; 2 3];
    c=c+1; r(c) = isequal(A, [1 2; 3 4]);
  catch
    c=c+1; r(c) = false;
  end


  %% size issues(?), "any()" not implemented
  D = [0 1; 2 3];
  A = sym(D);
  c=c+1; r(c) = isequal( size(any(A-D)), [1 2] );


  %% todo: bug? boolean not converted to sym
  c=c+1; r(c) = 0;
  %sym(1==1)
  %sym(1==0)
  %x - (1==1)
  %x - (1==0)



  %% Issue #9
  % nan == 1 should not be the sym "nan == 1" but rather bool false
  snan = sym(0)/0;
  c=c+1; r(c) = islogical(snan == 1);
  c=c+1; r(c) = ~isa(snan == 1, 'sym');
  c=c+1; r(c) = islogical([snan snan 1] == [10 12 1]);

  % these seem to work
  c=c+1; r(c) = islogical(sym(inf) == 1);
  c=c+1; r(c) = (sym(inf) == 1) == false;


  %% Issue #10
  %a = sym([1 2; 3 4])
  %f = sin(y);
  %subs(f, y, a);