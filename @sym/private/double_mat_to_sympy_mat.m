function z = double_mat_to_sympy_mat(A)

  % todo: split to fcn mat2list()
  [n,m] = size(A);
  Ac = cell(n,1);
  for i=1:n
    Ac{i} = num2cell(A(i,:));
  end

  %Ac = {{x 2}; {3 4}; {8 9}};

  d = size(A);
  if (length(d) > 2)
    error('conversion not supported for arrays of dim > 2');
  end

  cmd = [ 'def fcn(_ins):\n'  ...
          '    L = _ins[0]\n'  ...
          '    M = sp.Matrix(L)\n'  ...          
          '    return (M,)\n' ];
  %z = python_sympy_cmd(cmd, d(1), d(2), A(:));
  z = python_sympy_cmd(cmd, Ac);

