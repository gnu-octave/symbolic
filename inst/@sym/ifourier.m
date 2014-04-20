function f = ifourier(F,k,x)
%IFOURIER   Symbolic inverse Fourier transform

  if (nargin < 3)
    syms k
    warning('todo: check SMT for 2nd argument behavoir');
  end

  cmd = [ 'd = sp.inverse_fourier_transform(*_ins)\n' ...
          'return (d,)' ];

  f = python_cmd (cmd, sym(F), sym(k), sym(x));

