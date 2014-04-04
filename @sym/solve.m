function out = solve(varargin)
%SOLVE   Symbolic solutions of eqns and systems
%   solve(x==2*x+6, x)
%   solve(eq1, eq2, var1, var2)
%   solve(eq1,...,eqn, var1,...,varn)
%
%   todo: omitting the vars should work too
%   solve(eq1,...,eqn)
%
%   todo: out is a python list

  n = nargin;
  eqn = varargin(1:n/2)
  vars = varargin(n/2+1:n)

  cmd = [ 'def fcn(_ins):\n'                                          ...
          '    sys.stderr.write("pydebug: " + str(_ins) + "\\n")\n'   ...
          '    d = sp.solve(*_ins, dict=True)\n'                       ...
          '    sys.stderr.write("pydebug: " + str(d) + "\\n")\n'      ...
          '    return (d,)\n' ];
  out = python_sympy_cmd (cmd, eqn, vars);
