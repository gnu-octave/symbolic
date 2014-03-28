function t = eq(x,y)
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
%         DE = diff(f,x,x) + f
%      This does seem to be compatible with how the Matlab Symbolic
%      Toolbox *can* be used but might be unexpected for some
%      users.  Not sure what can be done other than make a subclass
%      for expressions with equals signs...



  if isscalar(x) && isscalar(y)
    try
      a = double(x);
      b = double(y);
      t = a == b;
      return
    catch
      %disp('caught double failure')
    end
    warning('possibly confusing result for Matlab Symbolic Toolbox users')
    t = x - y;


  elseif isscalar(x) && ~isscalar(y)
    error('todo')

  elseif ~isscalar(x) && isscalar(y)
    t = (y == x);

  else  % both are arrays
    assert_same_shape(x,y);
    warning('todo not reliable for arrays');
    t = x;
    for j = 1:numel(x)
      %t(j) = (x(j) == y(j));
      temp = (x(j) == y(j));
      if (isbool(temp))
        %warning('todo we need sym t/f values for this?')
        if temp
          t(j) = 1;
        else
          t(j) = 0;
        end
      else
        t(j) = temp
      end 
    end
  end

