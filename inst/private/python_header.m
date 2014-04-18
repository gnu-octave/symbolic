function s = python_header()
%private

  %s = sprintf('import sympy as sp\nimport pickle\n\n');

  %s = fileread('python_header.py');
  % FIXME how do we get the path?  otherwise use makefile to embed
  %       the .py in .m
  [f,msg] = fopen('private/python_header.py');
  if (f == -1)
    error(['Error reading python header: ' msg])
  end
  A = '';
  while(1)
    s = fgets (f);
    if (ischar (s))
      A = [A s];
    else
      break
    end
  end
  fclose(f);
  s = A;
  return

