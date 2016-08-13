function obj = check_and_convert(var_pyobj)
  persistent builtins
  persistent sp
  if isempty(builtins)
    builtins = pyeval("__builtins__");
    sp = pyeval("sympy");
  end

  is_list = py.isinstance(var_pyobj, py.tuple({builtins.list, builtins.tuple}));
  if is_list
    var_pyobj = py.list(var_pyobj);
    n = length(var_pyobj);
  else
    n = 1;
  end

  obj = {};
  for i=1:n
    if is_list
      cur_pyobj = var_pyobj{i};
    else
      cur_pyobj = var_pyobj;
    end

    if(py.isinstance(cur_pyobj, sp.Matrix) && isequal(cur_pyobj.shape, py.tuple({1, 1})))
      cur_pyobj = cur_pyobj.__getitem__(py.tuple({int8(0),int8(0)}));
    end

    if py.isinstance(cur_pyobj, builtins.dict)
      cur_keys = cur_pyobj.keys();
      dict_to_struct = true;
      for j = 1:length(cur_keys)
        dict_to_struct = dict_to_struct && py.isinstance(cur_pyobj.keys(){j}, py.tuple({sp.Basic, sp.MatrixBase, builtins.str}));
      end
    else
      dict_to_struct = false;
    end

    is_list_curvar = py.isinstance(cur_pyobj, py.tuple({builtins.list, builtins.tuple}));

    if is_list_curvar
      obj{i} = check_and_convert(cur_pyobj);
    elseif dict_to_struct
      %if cur_var is dictionary with symbols/strings as keys then convert it to a struct
      allKeys = cur_pyobj.keys();
      obj{i} = struct ();
      for j = 1:length(allKeys)
        obj{i}.(py.str(allKeys{j})) = check_and_convert(cur_pyobj{allKeys{j}}){1};
      end
    else
      is_sym = isequal(cur_pyobj, py.None) || py.isinstance(cur_pyobj, py.tuple({sp.Basic, sp.MatrixBase}));

      if is_sym
        obj{i} = get_sym_from_python(cur_pyobj, sp);
      else
        obj{i} = cur_pyobj;
      end
    end
  end
end
