%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod @@sym simplify (@var{x})
%% @defmethodx @@sym simplify (@var{x}, @var{y})
%% Simplify an expression.
%%
%% @var{y} can be 'special' or 'complete'.
%% 'special' will simplify special function with identities.
%% 'complete' will replace the identities and then simplify.
%%
%% Example:
%% @example
%% @group
%% syms x
%% p = x^2 + x + 1
%%   @result{} p = (sym)
%%        2
%%       x  + x + 1
%% q = horner (p)
%%   @result{} q = (sym) x⋅(x + 1) + 1
%% @end group
%%
%% @group
%% d = p - q
%%   @result{} d = (sym)
%%        2
%%       x  - x⋅(x + 1) + x
%%
%% isAlways(p == q)
%%   @result{} 1
%%
%% simplify(p - q)
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% When @var{y} is 'special':
%% @example
%% @group
%% syms x
%% simplify(beta(x, 1), 'special')
%%   @result{} ans = (sym)
%%    Γ(x)  
%%  ────────
%%  Γ(x + 1)
%% @end group
%% @end example
%%
%% When @var{y} is 'complete':
%% @example
%% @group
%% syms x
%% simplify(beta(x, 1), 'complete')
%%   @result{} ans = (sym)
%%  1
%%  ─
%%  x
%% @end group
%% @end example
%%
%% @seealso{@@sym/isAlways, @@sym/factor, @@sym/expand, @@sym/rewrite}
%% @end defmethod

%% Source: http://docs.sympy.org/dev/tutorial/simplification.html

function y = simplify(x, y)

  if (nargin == 1)
    y = python_cmd('return simplify(*_ins),', x);
  elseif ( strcmp( y, 'special'))
    y = python_cmd('return expand_func(*_ins),', x);
  elseif ( strcmp( y, 'complete'))
    y = python_cmd('return simplify(expand_func(*_ins)),', x);
  else
    print_usage ();
  end

end


%!shared x,p,q
%! syms x
%! p = x^2 + x + 1;
%! q = horner (p);
%!assert(~isequal( p - q, 0))
%!assert(isequal( simplify(p - q), 0))

%!test
%! syms x
%! A = simplify(beta(x, 1), 'special');
%! B = gamma(x)/gamma(x+1);
%! assert( isequal( A, B ))

%!test
%! syms x
%! A = simplify(beta(x, 1), 'complete');
%! B = 1/x;
%! assert( isequal( A, B ))
