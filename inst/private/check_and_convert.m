%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2016 Colin B. Macdonald
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


  if (~ py.isinstance(var_pyobj, list_or_tuple))
    var_pyobj = {var_pyobj};
  end

  obj = {};
  for i = 1:length(var_pyobj)
    x = var_pyobj{i};

    if (py.isinstance(x, sp.Matrix) && isequal(x.shape, tuple_1_1))
      %TODO: Probably better if supported via pytave
      % https://bitbucket.org/mtmiller/pytave/issues/63
      x = x.__getitem__(tuple_0_0);
    end

    if (py.isinstance(x, list_or_tuple))
      obj{i} = check_and_convert(x);
    elseif (py.isinstance(x, builtins.dict))
      make_str_keys = pyeval ('lambda x: {str(k): v for k, v in x.items()}');
      x = pycall (make_str_keys, x);
      s = struct (x);
      % make sure values are converted to sym
      s = structfun (@(t) check_and_convert (t){:}, s, 'UniformOutput', false);
      obj{i} = s;
    elseif (isequal(x, py.None) || py.isinstance(x, _sym))
      obj{i} = get_sym_from_python(x);
    else
      obj{i} = x;
    end
  end
end
