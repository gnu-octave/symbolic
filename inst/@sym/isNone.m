%% Copyright (C) 2016 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {@var{tf} =} isNone (@var{x})
%% Return true if symbolic expression is Python object None.
%%
%% Python has a @code{None} object.
%%
%% Example:
%% @example
%% @group
%% a = python_cmd('return None')
%%   @result{} a = (sym) None
%% isNone(a)
%%   @result{} ans =  1
%% @end group
%% @end example
%%
%% @seealso{isnan, isinf}
%% @end deftypefn

function tf = isNone(x)

  if (nargin ~= 1)
    print_usage ();
  end

  tf = uniop_bool_helper(x, 'lambda a: a is None');

end


%!test
%! None = python_cmd ('return None');

%!shared None
%! None = python_cmd ('return None');

%!assert (isNone(None))
%!assert (~isNone(sym('x')))
%!assert (islogical(isNone(None)))

%!test
%! a = [1 None];
%! a = [None None];
%! a = [None; 1];
%! a = [None; None];
%! a = [None 2; 3 None];

%!test
%! a = sym([1 2]);
%! a(1,2) = None;
%! assert (isequal (a, [sym(1) None]))
