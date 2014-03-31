function t = neweq(x,y)
%EQ   Test for symbolic equality, or define equation
%   a == b tries to convert both a and b to numbers and compare them
%   as doubles.  If this fails, it defines a symbolic expression for a
%   == b.
%


  if isscalar(x) && isscalar(y)
    x = sym(x);  % todo
    y = sym(y);  % todo

    true_pickle = sprintf('I01\n.');
    false_pickle = sprintf('I00\n.');
    cmd = [ 'def fcn(_ins):\n'  ...
            '    d = sp.Eq(_ins[0], _ins[1])\n'  ...
            '    return (d,)\n' ];
    z = python_sympy_cmd (cmd, x, y);

    if (strcmp(z.pickle, true_pickle))
      t = true;
    elseif (strcmp(z.pickle, false_pickle))
      t = false;
    else
      t = z;   % the releq
    end

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

