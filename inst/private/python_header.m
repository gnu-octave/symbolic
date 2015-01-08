function s = python_header()
%private

  persistent PyStrCache

  if (isempty(PyStrCache))
    s = fileread('private/python_header.py');
    PyStrCache = s;
  end
  s = PyStrCache;
end
