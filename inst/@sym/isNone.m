%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym isNone (@var{x})
%% Return true if symbolic expression is Python object None.
%%
%% Python has a @code{None} object.
%%
%% Example:
%% @example
%% @group
%% @c FIXME: pycall_sympy__ is implementation detail, maybe better
%% @c to avoid it in our docs.
%% a = pycall_sympy__ ('return None')
%%   @result{} a = (sym) None
%% isNone(a)
%%   @result{} ans =  1
%% @end group
%% @end example
%%
%% @seealso{@@sym/isnan, @@sym/isinf}
%% @end defmethod


function tf = isNone(x)

  if (nargin ~= 1)
    print_usage ();
  end

  tf = uniop_bool_helper(x, 'lambda a: a is None');

end


%!test
%! None = pycall_sympy__ ('return None');

%!shared None
%! None = pycall_sympy__ ('return None');

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
%! assert (isequal (a, [sym(1) None]));

%!assert (isequal (None(1), None));
%!error None(None);
%!error <must be integer> x=sym('x'); x(None);
%!error <must be integer> x=1; x(None);
%!error None(None);
%!error 1 + None;
%!error None - 1;
%!error 6*None;
%!error 2**None;
%!error [1 2].*None;
%!error isconstant(None);
%!error nnz(None);

% FIXME: possibly later we will want e.g., None -> false
%!error <AttributeError> logical(None);
%!error <AttributeError> isAlways(None);
%!error <AttributeError> logical([sym(true) None]);
%!error <AttributeError> isAlways([sym(true) None]);

%!assert (isequal (children(None), None))
%!assert (isequal (repmat(None, 1, 2), [None None]))

%!assert (isequal (fliplr(None), None))
%!assert (isequal (flipud(None), None))
