function s = python_header()
%private

  persistent PyStrCache

  if (isempty(PyStrCache))
    % FIXME: does Octave 3.6 have fileread?
    PyStrCache = fileread('private/python_header.py');
  end

  s = PyStrCache;

end
