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
%% @deftypefn  {Function File} {@var{y} =} reshape (@var{x}, @var{n}, @var{m})
%% @deftypefnx {Function File} {@var{y} =} reshape (@var{x}, [@var{n}, @var{m}])
%% Change the shape of a symbolic array.
%%
%% @seealso{size}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function z = reshape(a, n, m)

  % reshaping a double array with sym sizes
  if ~(isa(a, 'sym'))
    if (nargin == 2)
      z = reshape(a, double(n));
    else
      z = reshape(a, double(n), double(m));
    end
    return
  end

  if (nargin == 2)
    m = n(2);
    n = n(1);
  end

  cmd = [ '(A,n,m) = _ins\n'  ...
          'if A.is_Matrix:\n'  ...
          '    #return ( A.reshape(n,m) ,)\n' ...
          '    #sympy is row-based\n' ...
          '    return ( A.T.reshape(m,n).T ,)\n' ...
          'else:\n' ...
          '    return ( A ,)' ];

  z = python_cmd(cmd, sym(a), n, m);

