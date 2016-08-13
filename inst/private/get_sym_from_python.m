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

function retS = get_sym_from_python(var_pyobj, sp)
  pyexec('def sp_pretty_proxy(s, u): return sp.pretty(s, use_unicode=u)');
  ascii = pycall('sp_pretty_proxy', var_pyobj, false);
  unicode = pycall('sp_pretty_proxy', var_pyobj, true);

  str = sp.srepr(var_pyobj);
  flat = py.str(var_pyobj);

  if py.isinstance(var_pyobj, py.tuple({sp.Matrix, sp.ImmutableMatrix}))
    _d = py.list(var_pyobj.shape);
  elseif py.isinstance(var_pyobj, sp.MatrixExpr)
    shape_func = pyeval(strjoin({'lambda x : [float(r)',
                                 'if (isinstance(r, sp.Basic) and r.is_Integer)',
                                 'else float("nan") if isinstance(r, sp.Basic)',
                                 'else r for r in x.shape]'}, ' '));
    _d = pycall(shape_func, var_pyobj);
  else
    _d = {1, 1};
  end

  retS = sym([], str, [_d{1} _d{2}], flat, ascii, unicode);
end
