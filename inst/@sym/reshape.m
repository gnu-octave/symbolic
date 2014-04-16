function z = reshape(a, n, m)
%RESHAPE   Change the shape of a symbolic array

  % reshaping a double array with sym sizes
  if ~(isa(a, 'sym'))
    if (nargin == 2)
      z = reshape(a, double(n));
    else
      z = reshape(a, double(n), double(m));
    end
    return
  end

  if (nargin == 2)
    m = n(2);
    n = n(1);
  end

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (A,n,m) = _ins\n'  ...
          '    if A.is_Matrix:\n'  ...
          '        #return ( A.reshape(n,m) ,)\n' ...
          '        #sympy is row-based\n' ...
          '        return ( A.T.reshape(m,n).T ,)\n' ...
          '    else:\n' ...
          '        return ( A ,)\n' ];
 
  z = python_sympy_cmd(cmd, sym(a), n, m);

