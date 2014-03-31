function expr = make_undecl_symfun_rhs(s, vars)
%private
%
% todo: to move this code to the symfun constructor, need access to python_cmd

  %_f = Function("f")(x) 
  %cmd = sprintf('f = sp.Function("%s")(%s)\n', fname, fargs);

  if ~(isa (s, 'char'))
    error('takes a string');
  end


  i = strfind(s,'(');
  if ~(isscalar(i)) || (i < 2) || (isempty(i))
    error('invalid symfun string');
  end
  fname = s(1:(i-1));

  extra = sprintf('%s = sp.symbols("%s", cls=sp.Function)', fname, fname);

  cmd = sprintf( [ 'def fcn(_ins):\n'  ...
                   '    x = _ins\n' ] );
  %cmd = sprintf ('%s    _f = sp.Function("%s")(*x)\n', cmd, fname);
  cmd = sprintf ('%s    _f = %s(*x)\n', cmd, fname);
  cmd = sprintf ('%s    return (_f,)\n', cmd);
    
  %hack
  cmd = [extra '\n\n' cmd];

  %cmd, vars
  expr = python_sympy_cmd(cmd, vars{:});
