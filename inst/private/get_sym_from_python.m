%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2016, 2019 Colin B. Macdonald
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

function retS = get_sym_from_python(var_pyobj)
  persistent shape_func
  persistent sp
  persistent sp_matrix
  persistent tuple_1_1 tuple_0_0
  persistent use_unicode_false use_unicode_true
  if isempty(shape_func)
    shape_func = pyeval(strjoin({'lambda x : [float(r)',
                                 'if (isinstance(r, sp.Basic) and r.is_Integer)',
                                 'else float("nan") if isinstance(r, sp.Basic)',
                                 'else r for r in x.shape]'}, ' '));
    sp = py.sympy;
    sp_matrix = py.tuple({sp.Matrix, sp.ImmutableMatrix});
    use_unicode_false = pyargs('use_unicode', false);
    use_unicode_true = pyargs('use_unicode', true);
    tuple_1_1 = py.tuple ({1, 1});
    tuple_0_0 = py.tuple ({int8(0),int8(0)});
  end

  % Don't return 1x1 matrices
  if (py.isinstance(var_pyobj, sp_matrix) && isequal(var_pyobj.shape, tuple_1_1))
    % TODO: Probably better if supported via Pythonic
    % https://gitlab.com/mtmiller/octave-pythonic/issues/11
    var_pyobj = var_pyobj.__getitem__(tuple_0_0);
  end

  ascii = char (sp.pretty (var_pyobj, use_unicode_false));
  unicode = char (sp.pretty (var_pyobj, use_unicode_true));
  srepr = char (sp.srepr (var_pyobj));
  flat = char (py.str (var_pyobj));

  if py.isinstance(var_pyobj, sp_matrix)
    _d = var_pyobj.shape;
    % TODO: could use int64, but is size supposed to be double?
    sz = [double(_d{1}) double(_d{2})];
  elseif py.isinstance(var_pyobj, sp.MatrixExpr)
    _d = pycall(shape_func, var_pyobj);
    sz = [double(_d{1}) double(_d{2})];
  else
    sz = [1 1];
  end
  retS = sym([], srepr, sz, flat, ascii, unicode);
end
