function store_vars_in_python (varname, L)
%varname
%L
  persistent counter = round(100000*rand())

  for i = 1:numel(L)
    %i
    x = L{i};
    if (isa(x, 'sym'));
      pyexec([varname '.append(' char(x) ')'])
    elseif (iscell (x))
      tempname = [varname num2str(counter)];
      counter = counter + 1;
      pyexec ([tempname ' = []'])
      store_vars_in_python (tempname, x)
      pyexec([varname '.append(' tempname ')'])
    elseif (isscalar (x) && isnumeric (x))
      % workaround upstream PyTave bug: https://fixme.url.here
      % FIXME: add bug number, about making arrays [[42]] when passing 42
      pycall ('pystoretemp', x)
      if isinteger(x)
        pyexec ([varname '.append(int(_temp[0,0]))'])
      else
        pyexec ([varname '.append(_temp[0,0])'])
      end
    else
      pycall ('pystoretemp', x)
      pyexec ([varname '.append(_temp)'])
    end
  end
end
