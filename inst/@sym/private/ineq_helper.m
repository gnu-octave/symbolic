%% Copyright (C) 2014 Colin B. Macdonald
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

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function t = ineq_helper(op, fop, lhs, rhs, nanspecial)

  if (nargin == 4)
    nanspecial = 'S.false';
  end

  % FIXME: this will need to catch exceptions soon
  op = { 'def _op(lhs, rhs):'
         '    # workaround sympy nan behaviour, Issue #9'
         '    if lhs is nan or rhs is nan:'
        ['        return ' nanspecial]
        ['    return ' fop '(lhs, rhs)'] };

  t = elementwise_op (op, lhs, rhs);

end

