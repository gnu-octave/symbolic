function store_vars_in_python (varname, L)
  varname
  L

  for i = 1:numel(L)
    i
    x = L{i};
    if (isa(x, 'sym'));
      pycall('pystoretemp', sprintf(char(x)))
      pyexec([varname '.append(_temp)'])
    elseif (iscell (x))
      % FIXME: this is wrong, could be a collision.
      % instead, keep a counter, increase with depth...
      tempname = [varname num2str(round(100000*rand()))];
      pyexec ([tempname ' = []'])
      store_vars_in_python (tempname, x)
      pyexec([varname '.append(' tempname ')'])
    elseif (isscalar (x) && isnumeric (x))
      % workaround upstream PyTave bug: https://fixme.url.here
      % FIXME: add bug number, about making arrays [[42]] when passing 42
      pycall ('pystoretemp', x)
      pyexec ([varname '.append(_temp[0,0])'])
    else
      pycall ('pystoretemp', x)
      pyexec ([varname '.append(_temp)'])
    end
  end
end
