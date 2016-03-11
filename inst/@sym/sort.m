%% Copyright (C) 2014, 2015 Utkarsh Gautam
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
%% sort orders the elements in increasing order.
%% @example
%% @group
%% >> sort([sym(2),sym(1)])
%%   @result{} ans = (sym) [1  2]  (1×2 matrix)
%%
%% @end group
%% @end example
%% For matrices, sort orders the elements within columns
%% @example
%% @group
%% >> [s,i]=sort([sym(2),sym(1);sym(3),sym(0)])
%%   @result{} s = (sym 2×2 matrix)
%%
%%               ⎡2  0⎤
%%               ⎢    ⎥
%%               ⎣3  1⎦
%%
%%             i = 
%%
%%                1  2
%%                2  1
%%
%% @end group
%% @end example
%% @end deftypefn
%% Author: Utkarsh Gautam
%% Keywords: symbolic, sort

function [s,i] = sort(f)
	if isempty(f)
		s=f;
		i=f;
	else 
	  if isallconstant(f) 
	    [s,i]=sort(double(f));
	    s=sym(s);
	  else
	    error('Invalid Input')
	  end
	end    
end


%!test 
%! f = [sym(1),sym(0)];
%! sort(f);
%! expected = sym([0 , 1]);
%! assert (isequal(sort(f), expected));

%!test 
%! f = [sym(1)];
%! sort(f);
%! expected = sym(f);
%! assert (isequal(sort(f), expected));

%!test
%! f = [sym(3),sym(2),sym(6)];
%! [s,i] = sort(f); 
%! expected_s = sym([2  3  6]);
%! expected_i = [2 1 3];
%! assert (isequal(s,expected_s) && isequal(i,expected_i));

%!test 
%! f = [sym(1), sym(2);sym(2), sym(3); sym(3), sym(1)];
%! [s,i] = sort(f);
%! expected_s = ([sym(1) ,sym(1);sym(2) ,sym(2);sym(3) ,sym(3)]);
%! expected_i = ([1,3;2,1;3,2]);
%! assert (isequal(s,expected_s) && isequal(i,expected_i));

%!test 
%!assert (isequal (sort(sym([])), sym([])))

%!test 
%! f = [sym(1)];
%! sort(f);
%! expected = sym([1]);
%! assert (isequal(sort(f), expected));

%!xtest
%! error<'Invalid Input'> 
%! sym x;
%! f=[ sym(1) x];
%! sort(f);