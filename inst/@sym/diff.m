function z = diff(f, varargin)
%DIFF   Symbolic differentiation
%   diff(f, x);
%     differentiate symbolic expression f w.r.t. symbol x.
%
%   diff(f)
%   diff(f,x,x,x)
%   diff(f,x,y,x);
%   diff(f,x,2,y,3);
%   diff(sym(1))

  % simpler version, but gives error on differentiating a constant
  %cmd = 'return sp.diff(*_ins),';

  cmd = [ '# special case for one-arg constant\n'             ...
          'if (len(_ins)==1 and _ins[0].is_constant()):\n'    ...
          '    return (sp.numbers.Zero(),)\n'                 ...
          'd = sp.diff(*_ins)\n'                              ...
          'return (d,)' ];

  varargin = sym(varargin);
  z = python_cmd (cmd, sym(f), varargin{:});
