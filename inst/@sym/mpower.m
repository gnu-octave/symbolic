function z = mpower(x, y)
%^   Matrix power

  cmd = 'return _ins[0]**_ins[1],';

  if isscalar(x) && isscalar(y)
    z = python_cmd (cmd, sym(x), sym(y));

  elseif isscalar(x) && ~isscalar(y)
    error('TODO: scalar^array not implemented yet');

  elseif ~isscalar(x) && isscalar(y)
    % todo: sympy can do int and rat, then MatPow, check MST
    z = python_cmd (cmd, sym(x), sym(y));

  else  % two array's case
    error('TODO: array^array not implemented yet');
  end


%!test
%! syms x
%! assert(isequal(x^(sym(4)/5), x.^(sym(4)/5)))
