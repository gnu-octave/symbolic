function obj = check_and_convert(var_name)
  newl = sprintf('\n');

  pyexec(strjoin({ ...
     ['if isinstance(' var_name ', (list, tuple)):'],
      '    is_list = True',
     ['    if isinstance(' var_name ', tuple):'],
     ['        ' var_name ' = list(' var_name ')'],
      'else:',
      '    is_list = False'}, newl));
  is_list = pyeval('is_list');

  if is_list
    n = pyeval(['len(' var_name ')']);
  else
    n = 1;
  end

  obj = {};
  for i=1:n
    if is_list
      cur_var = sprintf('%s[%d]', var_name, i-1);
    else
      cur_var = var_name;
    end

    pyexec(strjoin({ ...
       ['temp = ' cur_var],
        'if isinstance(temp, sp.Matrix) and temp.shape == (1, 1):',
       ['    ' cur_var ' = temp[0, 0]']}, newl));

    is_dict_with_sym_keys_curvar = pyeval(['isinstance(', cur_var, ', dict) and len(' cur_var '.keys())>0 and isinstance(' cur_var, '.keys()[0], (sp.Basic, sp.MatrixBase))']);
    is_list_curvar = pyeval(['isinstance(', cur_var, ', (list, tuple))']);

    if is_list_curvar
      obj{i} = check_and_convert(cur_var);
    elseif is_dict_with_sym_keys_curvar
      %if cur_var is dictionary with symbols as keys then convert it to a struct
      pyexec(strjoin({'_allKeysStr = []',
                      '_allValues = []',
                      ['for key, value in ' cur_var '.iteritems():'],
                      '    _allKeysStr.append(str(key))',
                      '    _allValues.append(value)'}, newl));
      _allKeysStr = pyeval('_allKeysStr');
      obj{i} = struct ();
      for j = 1:numel(_allKeysStr)
        obj{i}.(_allKeysStr{j}) = get_sym_from_python(sprintf('_allValues[%d]', j-1));
      end
    else
      pyexec(strjoin({ ...
         ['if ' cur_var ' is None or isinstance(' cur_var ', (sp.Basic, sp.MatrixBase)):'],
          '    is_sym = True',
          'else:',
          '    is_sym = False'}, newl));
      is_sym = pyeval('is_sym');

      if is_sym
        obj{i} = get_sym_from_python(cur_var);
      else
        obj{i} = pyeval(cur_var);
      end
    end
  end
end
