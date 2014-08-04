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

%% -*- texinfo -*-
%% @deftypefn {Function File}  {@var{y} =} mod (@var{x}, @var{n})
%% Element-wise modular arithmetic on symbolic arrays and polynomials.
%%
%% If any of the entries contain variables, we assume they are
%% polynomials and convert their coefficients to mod @var{n}.
%%
%% @seealso{FIXME}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mod(x, n)

  isconst = isempty (findsymbols (x));

  if (isconst)
    cmd = [ '(x,n) = _ins\n' ...
            def_each_elem_binary() ...
            'def _op(a,b):\n' ...
            '    return a % b\n' ...
            'return _each_elem_binary(x,n,_op)' ];
    z = python_cmd (cmd, sym(x), sym(n));

    % or you can use a lambda:
    % return _each_elem_binary(x,n,lambda a,b: a % b)

  else
    %% its not constant, assume everything is poly and mod the coefficients
    z = x;
    for i = 1:numel(x)
      % t = x(i)
      idx.type = '()'; idx.subs = {i};
      t = subsref (x, idx);
      if (isscalar(n))
        m = n;
      else
        m = subsref (n, idx);
      end
      sv = symvar(t, 1);
      rhs = poly2sym (mod (sym2poly (t,sv), m), sv);
      %z(i) = rhs;
      z = subsasgn(z, idx, rhs);
    end
  end

end


%!assert (isequal (mod (sym(5),4), sym(1)))
%!assert (isequal (mod ([sym(5) 8],4), [1 0] ))
%!test
%! syms x
%! assert (isequal ( mod (5*x,3), 2*x ))
%!test
%! syms x
%! a = [7*x^2 + 3*x + 3  3*x; 13*x^4  6*x];
%! assert (isequal ( mod (a,3), [x^2 0; x^4 0] ))