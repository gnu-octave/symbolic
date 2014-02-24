function z = plus(a, b)
%
%

  a = sym(a);
  b = sym(b);

  f = fopen('sym_python_temp.py', 'w');
  fprintf(f, 'import sympy as sp\nimport pickle\n');

  fprintf(f, 'a = pickle.loads("""%s""")\n', a.pickle);
  fprintf(f, 'b = pickle.loads("""%s""")\n', b.pickle);
  fprintf(f, 'z = a + b\n');
  fprintf(f, 'print "__________"\n');
  fprintf(f, 'print str(z)\n');
  fprintf(f, 'print "__________"\n');
  fprintf(f, 'print pickle.dumps(z)\n');
  fclose(f);
  [status,out] = system('python sym_python_temp.py');
  if status ~= 0
    error('failed');
    out
  end
  A = regexp(out, '__________\n(.*)\n__________\n(.*)', 'tokens');
  s.text = A{1}{1};
  s.pickle = A{1}{2};
  z = class(s, 'sym');
