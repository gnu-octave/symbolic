function f = ifourier(F,k,x)
%IFOURIER   Symbolic inverse Fourier transform

  if (nargin < 3)
    syms k
    warning('todo: check SMT for 2nd argument behavoir');
  end

  cmd = [ 'def fcn(_ins):\n'                                      ...
          '    d = sp.inverse_fourier_transform(*_ins)\n'            ...
          '    return (d,)\n' ];

  f = python_sympy_cmd (cmd, sym(F), sym(k), sym(x));

