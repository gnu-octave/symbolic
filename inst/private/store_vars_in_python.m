function store_vars_in_python(var_name, varargin)
  is_list = false;
  if numel(varargin) >1
    is_list = true;
  end
  
  for i= 1:numel(varargin)
    cur_var = var_name
    x = varargin{i};
    store_cur_var = true;
    
    if(isa(x, 'sym'));
      pycall('pystoretemp', sprintf(char(x)));
      
    elseif(ischar(x))
      pycall('pyevalstoretemp', sprintf('str("%s")', x));
      
    elseif(ismatrix(x) && ~isscalar(x))
      % Currently only deals with 2-D matrix. TODO: implement for n-D matrix
      if(size(x,1)==1)
        x = x';
      end
      for i=1:size(x,1)
        store_vars_in_python(cur_var, x(i));
      end
      store_cur_var = false;  % don't call append for this, already done
      
    else
      pycall('pystoretemp', x);
    end
    
    if store_cur_var
      if is_list
        pyexec([cur_var '.append(_temp)']);
      else
        pyexec([cur_var ' = _temp']);
      end
    end
  end
end