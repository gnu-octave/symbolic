function y = double(x)
%DOUBLE   Convert symbolic to doubles

  fd = fopen('sym_python_temp.py', 'w');
  fprintf(fd, 'import sympy as sp\nimport pickle\n');
  fprintf(fd, 'x = pickle.loads("""%s""")\n', x.pickle);
  fprintf(fd, 'y = sp.N(x,30)\n');
  fprintf(fd, 's = "%%.30g" %% y\n');
  fprintf(fd, 'print "__________"\n');
  fprintf(fd, 'print s\n');
  fclose(fd);
  [status,out] = system('python sym_python_temp.py');
  if status ~= 0
    error('failed');
    out
  end
  A = regexp(out, '__________\n(.*)\n', 'tokens');
  y = str2double (A{1}{1});
  if (isnan (y))
    error('conversion failed?');
  end