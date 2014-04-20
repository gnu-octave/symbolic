function expr = make_undecl_symfun_rhs(s, vars)
%private
%
% FIXME: to move this code to the symfun constructor, need access to
% python_cmd (which we now have).

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

  %extra = sprintf('%s = sp.symbols("%s", cls=sp.Function)', fname, fname);

  %cmd = sprintf ('_f = %s(*_ins)\n', fname);
  cmd = sprintf ('_f = sp.Function("%s")(*_ins)\n', fname);
  cmd = sprintf ('%sreturn (_f,)', cmd);

  %hack
  %cmd = [extra '\n\n' cmd];

  %cmd, vars
  expr = python_cmd (cmd, vars{:});
