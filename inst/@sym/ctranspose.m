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
%% @deftypefn  {Function File} {@var{y} =} ctranspose (@var{x})
%% Conjugate (Hermitian) transpose of a symbolic array.
%%
%% @seealso{transpose, conj}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = ctranspose(x)

  cmd = { 'x = _ins[0]' ...
          '# special case for Boolean terms' ...
          'if x.has(S.true) or x.has(S.false):' ...
          '    def sf(x):' ...
          '        if x in (S.true, S.false):' ...
          '            return x' ...
          '        return x.conjugate()' ...
          '    if x.is_Matrix:' ...
          '        z = x.T' ...
          '        return z.applyfunc(lambda a: sf(a)),' ...
          '    else:' ...
          '        return sf(x),' ...
          'if x.is_Matrix:'  ...
          '    return x.H,' ...
          'else:' ...
          '    return x.conjugate(),' };

  z = python_cmd (cmd, x);

end


%!test
%! x = sym(1);
%! assert (isequal (x', x))

%!assert (isempty (sym([])'))

%!test
%! % conjugate does nothing to real x
%! syms x real
%! assert (isequal (x', x))

%!test
%! % complex
%! syms x
%! assert (isequal (x', conj(x)))

%!test
%! % complex array
%! syms x
%! A = [x 2*x];
%! B = [conj(x); 2*conj(x)];
%! assert(isequal(A', B))

%!test
%! A = [1 2; 3 4];
%! assert(isequal( sym(A)' , sym(A') ))
%!test
%! A = [1 2] + 1i;
%! assert(isequal( sym(A)' , sym(A') ))

%!test
%! % true/false
%! t = sym(true);
%! f = sym(false);
%! assert (isequal ( t', t))
%! assert (isequal ( f', f))

%!test
%! % more true/false
%! syms x
%! A = [x true 1i];
%! B = [conj(x); true; -sym(1i)];
%! assert (isequal ( A', B))
