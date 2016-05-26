function obj = check_and_convert()
  newl = sprintf('\n');
  
  str_check_is_list = strjoin({'if isinstance(_outs, (list, tuple)):',
                              '  is_list = True',
                              'else:',
                              '  is_list = False'},newl);
  pyexec(str_check_is_list);
  is_list = pyeval('is_list');
  
  if is_list
    n = pyeval('len(_outs)');
  else
    n = 1;
  end
  
  obj = {};
  for i=1:n
    if is_list
      cur_var = sprintf('_outs[%d]', i-1);
    else
      cur_var = sprintf('_outs');
    end
    
    str_check_is_sym = strjoin({strjoin({'if ', cur_var, ' is None or isinstance(', cur_var, ', (sp.Basic, sp.MatrixBase)):'}),
                                '  is_sym = True',
                                'else:',
                                '  is_sym = False'},newl);
    pyexec(str_check_is_sym);
    is_sym = pyeval('is_sym');
    
    if is_sym
      obj(end+1) = {get_sym_from_python(cur_var)};
    else
      obj(end+1) = {pyeval(cur_var)};
    end
  end
  
  if n==1
    obj = obj{1};
  end
end