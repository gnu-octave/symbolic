function t = eq(a,b)
%EQ   Test for symbolic equality, or define equation
%   a == b tries to convert both a and b to numbers and compare them
%   as doubles.  If this fails, it defines a symbolic expression for a
%   == b (namely a - b with implicit equality to 0).
%
%   Implementation notes:
%      SymPy doesn't seem to have an equals sign: expressions are
%      just implicitly equal to 0.  See, e.g.,
%      [http://docs.sympy.org/0.7.2/tutorial.html#differential-equations]
%      So the construction
%         DE = diff(f,x,x) + f == 0
%      will be the same as
%         DE = diff(f,x,x) + f == 0
%      This does seem to be compatible with how the Matlab Symbolic
%      Toolbox *can* be used but might be unexpected for some
%      users.  Not sure what can be done other than make a subclass
%      for expressions with equals signs...

  try
    a = double(a);
    b = double(b);
    t = a == b;
    return
  catch
    %disp('caught double failure')
  end
  warning('possibly confusing result for Matlab Symbolic Toolbox users')
  t = a - b;

