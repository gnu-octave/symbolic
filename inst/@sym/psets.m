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
%% @defmethod @@sym psets (@var{x})
%% Return a cell of sets (ProductSets) input of the @var{x}.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (2), 3);
%% b = interval (sym (4), 5);
%% c = interval (sym (1), 7);
%%
%% psets (complexregion (a * b))
%%   @result{} ans = (sym) [2, 3] × [4, 5]
%% @end group
%% @end example
%%
%% @example
%% @group
%% psets (complexregion (a * b + b * c))
%%   @result{} ans = (sym 2×1 matrix)
%%       ⎡[2, 3] × [4, 5]⎤
%%       ⎢               ⎥
%%       ⎣[4, 5] × [1, 7]⎦
%% @end group
%% @end example
%%
%% @end defmethod


function varargout = psets(x)
  if (nargin ~= 1)
    print_usage ();
  end

  out = python_cmd ('return Matrix(_ins[0].psets)', sym (x));

  if nargout == 0 || nargout == 1
    varargout = {out};
  else
    assert (~isequal (length (out), nargout), ['This only have ' num2str(length (out)) ' returns, please set the correct number of outputs']);
    varargout = out;
  end
end


%!test
%% a = interval (sym (1), 9);
%% b = interval (sym (4), 6);
%% sol = {a * b};
%% r = psets (complexregion (a * b));
%% assert (isequal (r, sol))

%!test
%% a = interval (sym (1), 9);
%% b = interval (sym (4), 6);
%% c = interval (sym (2), 3);
%% sol = {a * b; c * b};
%% r = psets (complexregion (a * b + c * b));
%% assert (isequal (r, sol))
