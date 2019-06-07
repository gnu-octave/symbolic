%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2016, 2017 Colin B. Macdonald
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
  persistent list_or_tuple
  persistent _sym
  persistent string_types
  persistent integer_types
  if isempty(builtins)
    builtins = pyeval("__builtins__");
    list_or_tuple = py.tuple({builtins.list, builtins.tuple});

    sp = py.sympy;
    _sym = py.tuple({sp.Basic, sp.MatrixBase});
    string_types = sp.compatibility.string_types;
    integer_types = sp.compatibility.integer_types;
  end


  if (~ py.isinstance(var_pyobj, list_or_tuple))
    var_pyobj = {var_pyobj};
  end

  obj = {};
  for i = 1:length(var_pyobj)
    x = var_pyobj{i};

    if (~ isa (x, 'pyobject'))
      obj{i} = x;
    elseif (py.isinstance(x, _sym) || isequal(x, py.None))
      obj{i} = get_sym_from_python(x);
    elseif (py.isinstance(x, list_or_tuple))
      obj{i} = check_and_convert(x);
    elseif (py.isinstance (x, string_types))
      obj{i} = char (x);
    elseif (py.isinstance(x, builtins.dict))
      make_str_keys = pyeval ('lambda x: {str(k): v for k, v in x.items()}');
      x = pycall (make_str_keys, x);
      s = struct (x);
      % make sure values are converted to sym
      s = structfun (@(t) check_and_convert (t){:}, s, 'UniformOutput', false);
      obj{i} = s;
    elseif (py.isinstance(x, integer_types))
      if (py.isinstance(x, pyeval('bool')))
        error ('unexpected python bool')
      end
      if (abs (double (x)) > intmax ('int64'))
        error ('precision would be lost converting integer larger than %ld', ...
               intmax ('int64'))
      end
      obj{i} = int64 (x);
    else
      warning ('OctSymPy:pythonic_no_convert',
               sprintf ('something was not converted from pyobject: %s',
                       char (x)))
      obj{i} = x;
    end
  end
end
