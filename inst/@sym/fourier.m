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
%% @deftypefn  {Function File} {@var{FF} =} fourier (@var{f}, @var{x}, @var{k})
%% Symbolic Fourier transform.
%%
%% FIXME: doc, examples
%%
%% @seealso{laplace}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function F = fourier(f,x,k)

  if (nargin < 3)
    syms k
    warning('todo: check SMT for 2nd argument behavoir');
  end

  cmd = [ 'd = sp.fourier_transform(*_ins)\n' ...
          'return (d,)' ];

  F = python_cmd (cmd, sym(f), sym(x), sym(k));

end


%!test
%! syms x k
%! f = exp(-x^2);
%! F = fourier(f,x,k);
%! g = ifourier(F,k,x);
%! assert(isequal(f,g))
