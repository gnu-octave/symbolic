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
%% @deftypefn  {Function File} {@var{d} =} size (@var{x})
%% @deftypefnx {Function File} {[@var{n}, @var{m}] =} size (@var{x})
%% Return the size of a symbolic array.
%%
%% @seealso{length,numel}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [n,m] = size(x)

  n = x.size;
  if (nargout == 2)
    m = n(2);
    n = n(1);
  end

  return


  %% FIXME: the old implementation before sym objs cached size
  cmd = [ 'x = _ins[0]\n'  ...
          '#dbout("size of " + str(x))\n'  ...
          'if x.is_Matrix:\n'  ...
          '    d = x.shape\n'  ...
          'else:\n'  ...
          '    d = (1,1)\n'  ...
          'return (d[0],d[1],)' ];
  [n,m] = python_cmd(cmd, x);
  if (nargout <= 1)
    n = [n m];
  end
