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
%% @defmethod @@sym point (@var{x})
%% @defmethodx @@sym point (@var{x}, @var{y})
%% @defmethodx @@sym point (@var{x}, @var{y}, @var{dor})
%% Represent a point or a set of points.
%% The plus of two points is the concatenation of it.
%%
%% Example:
%% @example
%% @group
%% point (sym (1), 2)
%%   @result{} ans = (sym) (1, 2)
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms x
%% point (x, x^2)
%%   @result{} ans = (sym)
%%       ⎛    2⎞
%%       ⎝x, x ⎠
%% @end group
%% @end example
%%
%% Check if exist the point in a space:
%% @example
%% @group
%% space = interval (sym (0), 7) * interval (sym (4), 9);
%% p = point (sym (6), 7);
%% contains (p, space)
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @end defmethod


function y = point(varargin)
  varargin = cellfun(@sym, varargin, 'UniformOutput', false);
  y = elementwise_op ('lambda x: S(tuple(x)) if len(x) > 1 else S(*x)', varargin);
end


%!test
%! a = point (sym (1));
%! b = point (sym (-1));
%! c = interval (sym (0), 3);
%! assert (logical (contains (a, c)))
%! assert (~logical (contains (b, c)))

%!test
%! a = point (sym (2), 2);
%! b = point (sym (-1), 2);
%! c = interval (sym (0), 5) * finiteset (1, 2, 3);
%! assert (logical (contains (a, c)))
%! assert (~logical (contains (b, c)))
