function z = log2(x)
%LOG2  Symbolic log base 2 function

  cmd = [ '(x,) = _ins\n' ...
          'y = sp.log(x,2)\n' ...
          'return (y,)' ];

  z = python_cmd (cmd, x);

