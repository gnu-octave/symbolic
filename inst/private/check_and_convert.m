%% Copyright (C) 2016 Abhinav Tripathi, Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

function obj = check_and_convert(var_pyobj)
  persistent builtins
  persistent sp
  persistent tuple_1_1
  persistent tuple_0_0
  persistent list_or_tuple
  persistent _sym
  persistent sym_or_str
  if isempty(builtins)
    tuple_1_1 = py.tuple({1, 1});
    tuple_0_0 = py.tuple({int8(0),int8(0)});

    builtins = pyeval("__builtins__");
    list_or_tuple = py.tuple({builtins.list, builtins.tuple});

    sp = py.sympy;
    _sym = py.tuple({sp.Basic, sp.MatrixBase});
    sym_or_str = py.tuple({sp.Basic, sp.MatrixBase, builtins.str});
  end

  is_list = py.isinstance(var_pyobj, list_or_tuple);
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

    if(py.isinstance(cur_pyobj, sp.Matrix) && isequal(cur_pyobj.shape, tuple_1_1))
      cur_pyobj = cur_pyobj.__getitem__(tuple_0_0);
    end

    if py.isinstance(cur_pyobj, builtins.dict)
      cur_keys = cur_pyobj.keys();
      dict_to_struct = true;
      for j = 1:length(cur_keys)
        dict_to_struct = dict_to_struct && py.isinstance(cur_pyobj.keys(){j}, sym_or_str);
      end
    else
      dict_to_struct = false;
    end

    is_list_curvar = py.isinstance(cur_pyobj, list_or_tuple);

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
      is_sym = isequal(cur_pyobj, py.None) || py.isinstance(cur_pyobj, _sym);

      if is_sym
        obj{i} = get_sym_from_python(cur_pyobj);
      else
        obj{i} = cur_pyobj;
      end
    end
  end
end
