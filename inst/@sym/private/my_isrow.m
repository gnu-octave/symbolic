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
%% @deftypefn  {Function File} {@var{A} =} my_isrow (@var{x})
%% Return true if input is a row vector.
%%
%% @seealso{my_iscolumn}
%% @end deftypefn

function retval = my_isrow(x)

  t = exist('isrow');

  if ((t==2) || (t==5))
    retval = isrow(x);
  else
    % from Rik Wehbring's Octave function:
    sz = size (x);
    retval = (ndims (x) == 2 && (sz(1) == 1));
  end

end


%!assert(my_isrow([1]))
%!assert(my_isrow([1 2 3]))
%!assert(~my_isrow([]))
%!assert(~my_isrow([1 2 3]'))
%!assert(~my_isrow([1 2; 3 4]))
