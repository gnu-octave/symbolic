function soln = dsolve(de, y, ic)
%DSOLVE   Solve ODEs symbolically
%   Note y must be a symfun
%   todo: not sure sympy is really so strict: move to @sym
%   todo: ICs?


  % Usually we cast to sym in the _cmd call, but want to be
  % careful here b/c of symfuns
  if ~ (isa(de, 'sym') && isa(y, 'sym')
    error('inputs must be sym or symfun')
  end

  if (isscalar(de))
    cmd = [ '(_de,_y) = _ins\n'  ...
            'g = sp.dsolve(_de,_y)\n'  ...
            'return (g,)' ];

    soln = python_cmd (cmd, de, y);

    if (nargin == 3)
      warning('todo: ICs not supported yet')
      stop
    end


  else
    error('TODO system case')
  end

