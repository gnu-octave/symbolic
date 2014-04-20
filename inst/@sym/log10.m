function z = log10(x)
%LOG10  Symbolic log base 10 function

  cmd = [ '(x,) = _ins\n' ...
          'y = sp.log(x,10)\n' ...
          'return (y,)' ];

  z = python_cmd (cmd, x);

