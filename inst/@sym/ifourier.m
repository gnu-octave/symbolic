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
%% @deftypefn  {Function File} {@var{f} =} ifourier (@var{FF}, @var{k}, @var{x})
%% Symbolic inverse Fourier transform.
%%
%% FIXME: doc, examples
%%
%% @seealso{ilaplace}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function f = ifourier(F,k,x)

  if (nargin < 3)
    syms k
    warning('todo: check SMT for 2nd argument behavoir');
  end

  cmd = [ 'd = sp.inverse_fourier_transform(*_ins)\n' ...
          'return (d,)' ];

  f = python_cmd_string (cmd, sym(F), sym(k), sym(x));

end


%! % tests in fourier.m
%!assert(true)
