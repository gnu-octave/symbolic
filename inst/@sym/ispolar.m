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
%% @defmethod @@sym ispolar (@var{x})
%% Returns True if @var{x} is in polar form.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (2), 3);
%% b = interval (sym (4), sym (pi));
%% ispolar (complexregion (a * b))
%%   @result{} ans = (sym) False
%% @end group
%% @end example
%%
%% @example
%% @group
%% ispolar (complexregion (a * b, true))
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @end defmethod


function y = ispolar(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.polar', sym (x));
end


%!test
%! a = interval (sym (1), 2);
%! b = interval (sym (4), 5);
%! assert (logical (~ispolar (complexregion (a * b))))

%!test
%! a = interval (sym (1), 2);
%! b = interval (sym (4), sym (pi));
%! assert (logical (ispolar (complexregion (a * b, true))))
