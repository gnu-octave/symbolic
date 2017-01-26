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
%% @defmethod @@sym imageset (@var{f}, @var{d})
%% @defmethodx @@sym imageset (@var{f}, @var{x}, @var{d})
%% Image of a set under a mathematical function.
%% The imageset is created in the function @var{f} in the variable
%% @var{x} on the domain @var{d}, if @var{x} don't is passed will
%% be used the first var detected for symvar.
%%
%% Example:
%% @example
%% @group
%% syms x
%% f = x^2;
%% imageset (f, x, domain ('Complexes'))
%%   @result{} ans = (sym)
%%       ⎧ 2        ⎫
%%       ⎨x  | x ∊ ℂ⎬
%%       ⎩          ⎭
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms y
%% f = x^exp(y);
%% imageset (f, [x y], domain ('Naturals0'))
%%   @result{} ans = (sym 1×2 matrix)
%%       ⎡⎧ ⎛ y⎞         ⎫  ⎧ ⎛ y⎞         ⎫⎤
%%       ⎢⎨ ⎝ℯ ⎠         ⎬  ⎨ ⎝ℯ ⎠         ⎬⎥
%%       ⎣⎩x     | x ∊ ℕ₀⎭  ⎩x     | y ∊ ℕ₀⎭⎦
%% @end group
%% @end example
%%
%% @end defmethod


function y = imageset(f, a, b)

  if nargin == 1 || nargin > 3
    print_usage ();
  elseif nargin == 2
    b = a;
    b = symvar (f, 1);
    if isempty (b)
      error ('The function must be expression with a symbol.');
    end
  end
  y = elementwise_op ('lambda f, a, b: imageset(Lambda(a, f), b)', sym (f), sym (a), sym (b));

end


%!test
%! syms x
%! b = interval (sym (0), 4);
%! a = imageset (x^2, x, interval (sym (0), 2));
%! assert (isequal (a, b))

%!test
%! syms x
%! b = interval (sym (0), 20);
%! a = imageset(x*2, x, interval (sym (0), 10));
%! assert (isequal (a, b))
