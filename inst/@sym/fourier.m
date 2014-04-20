function F = fourier(f,x,k)
%FOURIER   Symbolic Fourier transform

  if (nargin < 3)
    syms k
    warning('todo: check SMT for 2nd argument behavoir');
  end

  cmd = [ 'd = sp.fourier_transform(*_ins)\n' ...
          'return (d,)' ];

  F = python_cmd (cmd, sym(f), sym(x), sym(k));

