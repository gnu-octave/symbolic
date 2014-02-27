function z = diff(f,varargin)
%DIFF   Symbolic differentiation
%   diff(f, x);
%     differentiate symbolic expression f w.r.t. symbol x.
%
%   diff(f)
%   diff(f,x,x,x)
%   diff(f,x,y,x);
%   diff(f,x,2,y,3);

    cmd = [ 'def fcn(ins):\n'  ...
            '    d = sp.diff(*ins)\n'  ...
            '    return (d,)\n' ];
    z = python_sympy_cmd (cmd, f, varargin{:});

