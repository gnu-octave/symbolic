%% Copyright (C) 2017 Lagu
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
%% @defmethod @@sym isemptyset (@var{x})
%% Return True if @var{x} is EmptySet.
%%
%% Example:
%% @example
%% @group
%% isemptyset (domain ('EmptySet'))
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @example
%% @group
%% isemptyset (domain ('Complexes'))
%%   @result{} ans = (sym) None
%% @end group
%% @end example
%%
%% @end defmethod


function y = isemptyset(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.is_EmptySet', sym (x));
end


%!test
%! a = isemptyset (interval (sym (0), 1));
%! if isa (a, 'sym')
%!   assert (isNone (a))
%! else
%!   assert (~logical (a));
%! end

%!test
%! a = isemptyset (domain ('EmptySet'));
%! if isa (a, 'sym')
%!   assert (~isNone (a))
%! else
%!   assert (logical (a));
%! end
