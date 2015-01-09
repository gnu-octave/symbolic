function s = python_header()
%private

  persistent PyStrCache

  if (isempty(PyStrCache))
    % FIXME: does Octave 3.6 have fileread?
    PyStrCache = fileread('private/python_header.py');
    % octave 3.6 workaround
    sz = size(PyStrCache);
    if (sz(1) > sz(2))
      PyStrCache = PyStrCache';
    end
  end

  s = PyStrCache;

end
