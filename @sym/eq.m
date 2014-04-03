function t = neweq(x,y)
%EQ   Test for symbolic equality, and/or define equation
%   a == b tries to convert both a and b to numbers and compare them
%   as doubles.  If this fails, it defines a symbolic expression for
%   a == b.  When each happens is a potential source of bugs!
%
%   NOTE: array case it hardcoded only check for equality (see logical()).
%   One could try to vectorize this defining equations but I think it gets
%   complicated when only some parts of the system reduce to bools.
%   todo: check how SMT behaves.

  if isscalar(x) && isscalar(y)
    %x = sym(x); y = sym(y);

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
    t = zeros(size(y), 'logical');
    for j = 1:numel(y)
      t(j) = logical(x == y(j));
    end


  elseif ~isscalar(x) && isscalar(y)
    t = (y == x);


  else  % both are arrays
    assert_same_shape(x,y);
    t = zeros(size(x), 'logical');
    for j = 1:numel(x)
      t(j) = logical(x(j) == y(j));
    end
  end
  return


    % see comments above
    for j = 1:numel(x)
      temp = (x(j) == y(j));
      if (isbool(temp))
        if temp
          t(j) = 1;
        else
          t(j) = 0;
        end
      else
        t(j) = temp;
      end
    end

