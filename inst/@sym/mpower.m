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
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = mpower(x, y);
    return
  end

    cmd = { 'x, y = _ins'
            'if x.is_Matrix and not y.is_Matrix:'
            '    return sympy.MatPow(x, y).doit(),'
            'else:'
            '    return x**y,'
          };

    z = python_cmd (cmd, sym(x), sym(y));

  % Dear hacker, wait from next release of sympy (actually .7.6.1) and replace with this function:
  % z = python_cmd ('return _ins[0]**_ins[1],', sym(x), sym(y))


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

%!test
%! % non-integer power
%! if (str2num(strrep(python_cmd ('return sp.__version__,'), '.', ''))<=761)
%!   disp('skipping known failure b/c SymPy <= 0.7.6.x')
%! else
%! A = sym([1 2; 0 3]);
%! B = A^pi;
%! C = [1 -1+3^sym(pi); 0 sym(3)^pi];
%! assert (isequal (B, C))
%! end

%!test
%! % matpow
%! if (str2num(strrep(python_cmd ('return sympy.__version__,'),'.',''))<=75)
%!   disp('skipping: fails on SymPy 0.7.5')
%! else
%! syms n
%! A = sym([1 2; 3 4]);
%! B = A^n;
%! C = 10 + B + B^2;
%! D = subs(C, n, 1);
%! E = 10 + A + A^2;
%! assert (isequal (D, E))
%! end

%!test
%! % matpow, sub in zero gives identity
%! if (str2num(strrep(python_cmd ('return sympy.__version__,'),'.',''))<=75)
%!   disp('skipping: fails on SymPy 0.7.5')
%! else
%! A = sym([1 2; 0 3]);
%! syms n;
%! B = A^n;
%! C = subs(B, n, 1);
%! assert (isequal (C, A))
%! C = subs(B, n, 0);
%! assert (isequal (C, sym(eye(2))))
%! end

%!error <NotImplementedError>
%! % scalar^array not implemented
%! syms x
%! A = [1 2; 3 4];
%! B = x^A;

%!error
%! A = sym([1 2; 3 4]);
%! B = A^A;
