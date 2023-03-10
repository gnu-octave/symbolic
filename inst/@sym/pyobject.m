%% Copyright (C) 2016-2017 Colin B. Macdonald
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

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod @@sym pyobject (@var{x})
%% Convert/cast a sym object to a pyobject.
%%
%% Example:
%% @example
%% @group
%% @c doctest: +SKIP_IF(~strcmp(sympref('ipc'), 'native'))
%% syms x
%% f = 2*sin(x/2);
%% pyobject(f)
%%   @result{} ans = [Python object of type sympy.core.mul.Mul]
%%
%%       2*sin(x/2)
%%
%% @end group
%% @end example
%% @seealso{@@sym/sympy, py, @@pyobject/pyobject}
%% @end defmethod


function y = pyobject (x)

  y = py.sympy.S (sympy (x));

  % Above is nice because it needs no imports.  But downside is some
  % things like NonElementaryIntegral and MatrixElement will fail.  See
  % e.g., commit 51a80384d5caea0db211e452d39f0b4f6b3778cc

  % Alternatively, with many imports (see python_header.py), this works:
  %y = pyeval (sympy (x));

end


%!test
%! try
%!   q = py.int(7);
%!   have_py = true;
%! catch
%!   have_py = false;
%! end
%! if (have_py)
%!   assert (isa (pyobject (sym ('x')), 'pyobject'))
%!   assert (regexp (char (class (pyobject (sym ('x')))), 'py\..*\.Symbol'))
%! end
