function F = fourier(f,x,k)
%FOURIER   Symbolic Fourier transform

  if (nargin < 3)
    syms k
    warning('todo: check SMT for 2nd argument behavoir');
  end

  cmd = [ 'def fcn(_ins):\n'                                      ...
          '    d = sp.fourier_transform(*_ins)\n'                 ...
          '    return (d,)\n' ];

  F = python_sympy_cmd (cmd, sym(f), sym(x), sym(k));

