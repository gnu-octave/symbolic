function z = diff(f,varargin)
%DIFF   Symbolic differentiation
%   diff(f, x);
%     differentiate symbolic expression f w.r.t. symbol x.
%
%   diff(f)
%   diff(f,x,x,x)
%   diff(f,x,y,x);
%   diff(f,x,2,y,3);

  cmd = [ 'def fcn(_ins):\n'                                      ...
          '    # special case for one-arg constant\n'             ...
          '    if (len(_ins)==1 and _ins[0].is_constant()):\n'    ...
          '        return (sp.numbers.Zero(),)\n'                 ...
          '    d = sp.diff(*_ins)\n'                              ...
          '    return (d,)\n' ];

  z = python_sympy_cmd (cmd, f, varargin{:});


  % simpler version but gives error on differentiating a constant
  % e.g. diff(sym(1))
  %cmd = [ 'def fcn(ins):\n'         ...
  %        '    d = sp.diff(*ins)\n' ...
  %        '    return (d,)\n' ];
