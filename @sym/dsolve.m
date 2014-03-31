function soln = dsolve(de, y, ic)
%DSOLVE   Solve ODEs symbolically
%   Note y must be a symfun
%   todo: not sure sympy is really so strict: move to @sym
%   todo: ICs?


  if (isscalar(de))
    cmd = [ 'def fcn(ins):\n'  ...
            '    (_de,_y) = ins\n'  ...
            '    g = sp.dsolve(_de,_y)\n'  ...
            '    return (g,)\n' ];
    soln = python_sympy_cmd(cmd, de, y);
 
    if (nargin == 3)
      warning('todo: ICs not supported yet')
      stop
    end


  else
    error('TODO system case')
  end

