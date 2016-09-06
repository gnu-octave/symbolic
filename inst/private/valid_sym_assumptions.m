%% Copyright (C) 2015 Colin B. Macdonald
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
%% @defun valid_sym_assumptions ()
%% Return list of valid assumptions.
%%
%% @end defun

%% Source: http://docs.sympy.org/dev/modules/core.html

function L = valid_sym_assumptions()

  persistent List

  if (isempty(List))

    %%FIXME: After a while update the list.
    cmd = {'r = []'
           'L = ["commutative", "complex", "imaginary", "real", "integer", "odd", "even", "prime", "composite", "zero", "nonzero", "rational", "algebraic", "trascendental", "irrational", "finite", "infinite", "negative", "nonnegative", "positive", "nonpositive", "hermitian", "antihermitian"]'
           'x = Symbol("x")'
           'for i in range(len(L)):'
           '    try:'
           '        q = eval("x.is_" + L[i])'
           '        r = r + [L[i]]'
           '    except:'
           '        pass'
           'return r,'};
    List = python_cmd(cmd);

  end

  L = List;

end
