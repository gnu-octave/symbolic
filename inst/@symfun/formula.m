%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @defmethod @@symfun formula (@var{f})
%% Return a symbolic expression for this symfun.
%%
%% This returns the expression that defines the function given by
%% the symfun @var{f}.  Typically this is the RHS of the symfun:
%% @example
%% @group
%% syms x
%% f(x) = sin(x);
%% formula(f)
%%   @result{} ans = (sym) sin(x)
%% @end group
%% @end example
%%
%% The command @ref{@@symfun/argname} gives the independent variables
%% of the @@symfun.  Basically, @code{argname} for the independent
%% variables and @code{formula} for the dependent expression.
%%
%% If the symfun @var{f} is abstract, this returns @var{f} as a
%% sym:
%% @example
%% @group
%% syms f(x)
%% formula(f)   % but note it's a sym
%%   @result{} ans = (sym) f(x)
%% @end group
%% @end example
%%
%% @seealso{@@symfun/argnames}
%% @end defmethod

function g = formula(f)
  g = f.sym;
end


%!test
%! % simple
%! syms x
%! f(x) = sin(x);
%! g = formula(f);
%! assert (isequal (g, sin(x)));

%!test
%! % concrete: return is a sym, not a symfun
%! syms x
%! f(x) = sin(x);
%! g = formula(f);
%! assert (~isa(g, 'symfun'));

%!test
%! % abstract: return is a sym, not a symfun
%! syms f(x)
%! g = formula(f);
%! assert (~isa(g, 'symfun'));
