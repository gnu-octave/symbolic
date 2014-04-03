function z = rdivide(x,y)
%./   elementwise forward slash division

  if isscalar(x) && isscalar(y)
    cmd = [ 'def fcn(ins):\n'  ...
            '    (x,y) = ins\n'  ...
            '    return (x/y,)\n' ];
    z = python_sympy_cmd (cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    z = make_zeros(size(y));
    for i = 1:numel(y)
      z(i) = x / y(i);
    end

  elseif ~isscalar(x) && isscalar(y)
    z = make_zeros(size(x));
    for i = 1:numel(x)
      z(i) = x(i) / y;
    end

  else  % two array's case
    z = make_zeros(size(x));
    for i = 1:numel(x)
      z(i) = x(i) / y(i);
    end
  end

