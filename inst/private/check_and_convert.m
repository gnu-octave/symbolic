function obj = check_and_convert(var_name)
  newl = sprintf('\n');
  
  pyexec(strjoin({strjoin({'if isinstance(', var_name, ', sp.Matrix) and ', var_name, '.shape == (1, 1):'}),
                  strjoin({'  ', var_name, ' = ', var_name, '[0, 0];'})}, newl));

  str_check_is_list = strjoin({strjoin({'if isinstance(', var_name, ', (list, tuple)):'}),
                              '  is_list = True',
                              'else:',
                              '  is_list = False'},newl);
  pyexec(str_check_is_list);
  is_list = pyeval('is_list');
  
  if is_list
    n = pyeval(strjoin({'len(', var_name, ')'}));
  else
    n = 1;
  end
  
  obj = {};
  for i=1:n
    if is_list
      cur_var = sprintf('%s[%d]', var_name, i-1);
    else
      cur_var = sprintf(var_name);
    end
    
    is_list_curvar = pyeval(strjoin({'isinstance(', cur_var, ', (list, tuple))'}));
    if is_list_curvar
      obj(end+1) = {check_and_convert(cur_var)};
    else
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
  end
end