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
%% @deftypefn  {Function File} {@var{A} =} my_iscolumn (@var{x})
%% Return true if input is a column vector.
%%
%% @seealso{my_isrow}
%% @end deftypefn

function retval = my_iscolumn(x)

  t = exist('iscolumn');

  if ((t==2) || (t==5))
    retval = iscolumn(x);
  else
    % from Rik Wehbring's Octave function:
    sz = size (x);
    retval = (ndims (x) == 2 && (sz(2) == 1));
  end

end


%!assert(my_iscolumn([1]))
%!assert(my_iscolumn([1 2 3]'))
%!assert(~my_iscolumn([]))
%!assert(~my_iscolumn([1 2 3]))
%!assert(~my_iscolumn([1 2; 3 4]))
