function t = eq(x,y)
%EQ   Test for symbolic equality, and/or define equation
%   a == b tries to convert both a and b to numbers and compare them
%   as doubles.  If this fails, it defines a symbolic expression for
%   a == b.  When each happens is a potential source of bugs!
%
%   Notes from SMT
%     * If any varibles appear in the matrix, then you get a matrix
%       of equalities:  syms x; a = sym([1 2; 3 x]); a == 1
%     * x==x is an equality, rather than "true".
%   We currently satisfy neither of these (TODO).
%
%   todo: from reading "Eq??", the following would seem to work:
%    >>> e = relational.Relational.__new__(relational.Eq, x, x)
%   (but passing this to solve() is still different from SMT
%
%   TODO: array case is hardcoded only to check for equality (see logical()).
%   to get the SMT, could do two passes through the array.


  if isscalar(x) && isscalar(y)

    % Note: sympy 0.7.4 Eq() returns python native bools,
    % but in 0.7.5 it has its own bool type.  Hence the d==True
    % stuff below

    % FIXME: we could hack around the SymPy NaN Eq behaviour, see Bug #9

    cmd = [ 'def fcn(_ins):\n'                   ...
            '    #dbout(_ins)\n'                 ...
            '    d = sp.Eq(_ins[0], _ins[1])\n'  ...
            '    #dbout(d)\n'                    ...
            '    if (d==True):\n'                ...
            '        return (True,)\n'           ...
            '    elif (d==False):\n'             ...
            '        return (False,)\n'          ...
            '    else:\n'                        ...
            '        return (d,)\n' ];

    % note: t could be bool or sym here
    t = python_sympy_cmd (cmd, sym(x), sym(y));


  elseif isscalar(x) && ~isscalar(y)
    %disp('eq matrix to scalar')
    t = logical(zeros(size(y)));
    for j = 1:numel(y)
      idx.type = '()';
      idx.subs = {j};
      %t(j) = logical(x == y(j));
      t(j) = logical(x == subsref(y, idx));
    end


  elseif ~isscalar(x) && isscalar(y)
    t = (y == x);


  else  % both are arrays
    % bug? for some reason, can't use () here, wtf?
    %x(1)
    assert_same_shape(x,y);
    %disp('eq two arrays: after assert')
    t = logical(zeros(size(x)));
    for j = 1:numel(x)
      idx.type = '()';
      idx.subs = {j};
      %t(j) = logical(x(j) == y(j));   % wtf!
      t(j) = logical(subsref(x,idx) == subsref(y,idx));
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

