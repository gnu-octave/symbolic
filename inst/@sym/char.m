%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod @@sym char (@var{x})
%% Return underlying string representation of a symbolic expression.
%%
%% Although not intended for general use, the underlying SymPy string
%% representation (“srepr”) can be recovered with this command:
%% @example
%% @group
%% syms x positive
%% srepr = char (x)
%%   @result{} srepr = Symbol('x', positive=True)
%% @end group
%% @end example
%%
%% It can then be passed directly to sym:
%% @example
%% @group
%% x2 = sym (srepr)
%%   @result{} x2 = (sym) x
%% x2 == x
%%   @result{} (sym) True
%% @end group
%% @end example
%%
%% @seealso{@@sym/disp, @@sym/pretty, sym}
%% @end defmethod


function s = char(x)

  s = x.pickle;

end


%!test
%! % issue #91: expose as string
%! syms x
%! s = char(x);
%! assert (strcmp (s, 'Symbol(''x'')'))
