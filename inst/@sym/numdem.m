%% Copyright (C) 2018-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {[@var{N}, @var{D}] =} numdem (@var{f})
%% Numerator and denominator of an expression.
%%
%% DEPRECATED: this was erroneously added and will be removed
%% in a future version.
%%
%% @seealso{@@sym/numden}
%% @end deftypemethod


function [N, D] = numdem(f)

  warning('OctSymPy:deprecated', 'numdem deprecated, you want "numden"')

  [N, D] = numden (f);

end


%!test
%! syms x
%! s = warning ('off', 'OctSymPy:deprecated');
%! [n, d] = numdem(1/x);
%! warning (s)
%! assert (isequal (n, sym(1)) && isequal (d, x))
