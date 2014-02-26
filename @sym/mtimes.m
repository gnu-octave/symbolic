function z = mtimes(a, b)
%*   Matrix multiplication of inputs
%
%   TODO: currently will fail if either input is a matrix

  a = sym(a);
  b = sym(b);

  if ~isscalar(a) || ~isscalar(b)
    error('TODO: non-scalar multiplication not implemented yet');
  end

  cmd = [ 'def fcn(ins):\n'  ...
          '    (a,b) = ins\n'  ...
          '    return (a*b,)\n' ];

  z = python_sympy_cmd(cmd, a, b);

