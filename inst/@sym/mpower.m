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
%% @deftypefn  {Function File}  {@var{z} =} mpower (@var{x}, @var{y})
%% Symbolic expression matrix exponentiation (^).
%%
%% We implement scalar ^ scalar and matrix ^ scalar.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mpower(x, y)

  % Dear hacker from the distant future... maybe you can delete this?
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:42735-workaround', ...
            'worked around octave bug #42735')
    z = mpower(x, y);
    return
  end


  if isscalar(x) && isscalar(y)
    cmd = 'return _ins[0]**_ins[1],';
    z = python_cmd (cmd, sym(x), sym(y));

  elseif isscalar(x) && ~isscalar(y)
    error('scalar^array not implemented');

  elseif ~isscalar(x) && isscalar(y)
    % FIXME: sympy can do int and rat, could use MatPow otherwise,
    % rather than error.  SMT just leaves them unevaluted.

    cmd = { 'x, y = _ins'
            'try:'
            '    z = x**y'
            '    r = True'
            'except NotImplementedError as e:'
            '    z = str(e)'
            '    r = False'
            'return (r, z)' };

    [r, z] = python_cmd (cmd, sym(x), sym(y));
    if ~r
      error('mpower: not implemented; sympy says: %s', z)
    end

  else  % two array's case
    error('array^array not implemented');
  end

end


%!test
%! syms x
%! assert(isequal(x^(sym(4)/5), x.^(sym(4)/5)))

%!test
%! % integer powers of scalars
%! syms x
%! assert (isequal (x^2, x*x))
%! assert (isequal (x^sym(3), x*x*x))

%!test
%! % array ^ integer
%! syms x y
%! A = [x 2; y 4];
%! assert (isequal (A^2, A*A))
%! assert (isequal (simplify(A^3 - A*A*A), [0 0; 0 0]))

%!test
%! % array ^ rational
%! Ad = [1 2; 0 3];
%! A = sym(Ad);
%! B = A^(sym(1)/3);
%! Bd = Ad^(1/3);
%! assert (max(max(abs(double(B) - Bd))) < 1e-14)

%!error <not implemented.*Only integer and rational values are supported>
%! A = sym([1 2; 0 3]);
%! B = A^sym(pi);

%!error <not implemented.*Only integer and rational values are supported>
%! A = sym([1 2; 0 3]);
%! syms x;
%! B = A^x;

%!error <not implemented>
%! % scalar^array not implemented
%! syms x
%! A = [1 2; 3 4];
%! B = x^A;

%!error <not implemented>
%! % array^array not implemented
%! A = sym([1 2; 3 4]);
%! B = A^A;
