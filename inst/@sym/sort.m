%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{g} =} sort (@var{f})
%% Symbolic Two Variable Taylor series.
%%
%% If omitted, @var{x} is chosen with @code{symvar} and @var{a}
%% defaults to zero.
%%
%% Key/value pairs can be used to set the order:
%% @example
%%change them
%% @group
%% >> f = [sym(1),sym(0)]
%% >> sort(f)
%% 	  ans = (sym) [0  1]  (1×2 matrix)
%% @end group
%% @end example
%%

%% Author: Utkarsh Gautam
%% Keywords: symbolic, sort

function s = sort(f)
  if isallconstant(f) 
    s=sym(sort(double(f)));
  else
    error('Invalid Input')
  end  
end


%!test 
%! f = [sym(1),sym(0)]
%! sort(f)	
%! expected = [0 ,1]
%! assert (isequal (sort(f), expected))


%!test
%! syms x
%! f = [sym(3),sym(2),sym(6)]
%! sort(f)	
%! expected = [2  3  6]
%! assert (isequal (sort(f), expected))

%!test 
%! f = [sym(1),sym(0.5)]
%! sort(f)	
%! expected = [1/2 ,1]
%! assert (isequal (sort(f), expected))

%! sym x
%! f=[sym(1) x]
%!	error <Invalid Input> sort (f)  # test that throws specific error