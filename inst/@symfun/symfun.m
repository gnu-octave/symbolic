%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{f} =} symfun (@var{expr}, @var{vars})
%% Define a symbolic function (not usually called directly).
%%
%% A symfun can be abstract or concrete.  An abstract symfun
%% represents an unknown function (for example, in a differential
%% equation).  A concrete symfun represents a known function such
%% as f(x) = sin(x).
%%
%% @strong{IMPORTANT}: are you getting sym's with names like
%% @code{pleaseReadHelpSymFun}?  This probably happens because the
%% following is @strong{not} the way to create an abstract symfun:
%% @example
%% f = sym('f(x)')
%% @end example
%% Instead, use @code{f(x)} on the left-hand side:
%% @example
%% f(x) = sym('f(x)')
%% @end example
%%
%%
%% Note that it is not usually necessary to call symfun directly,
%% you can use sym and syms.  Examples:
%% @example
%% x = sym('x')
%% f = symfun(sin(x), x)
%% f(x) = sin(x)  % same thing
%% @end example
%%
%% @example
%% x = sym('x')
%% y = sym('y')
%% f = symfun(x*y, [x y])
%% f(x,y) = x*y  % same thing
%% @end example
%%
%% Abstract functions: you can use sym/syms:
%% @example:
%% syms f(x) g(x,y)
%% @end example
%%
%% or
%% @example
%% x = sym('x')
%% y = sym('y')
%% f(x) = sym('f(x)')
%% g(x,y) = sym('g(x,y)')
%% @end example
%%
%%
%% To build abstract functions with symfun directly, the call to
%% symfun needs a string for @var{expr}.  It should be just the
%% function name (without the @code{(x,y)}).
%% @example
%% x = sym('x')
%% y = sym('y')
%% f = symfun('f', x)
%% g = symfun('g', [x y])
%% @end example
%% However, for interaction with @code{sym()}, it currently can
%% include the @code{(x,y)}.
%%
%%
%% @seealso{sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function f = symfun(expr, vars)

  if (nargin == 0)
    % octave docs say need a no-argument default for loading from files
    expr = sym(0);
    vars = sym('x');
  elseif (nargin == 1)
    error('takes two input arguments')
  end

  % if the vars are in a sym array, put them in a cell array
  if (isa( vars, 'sym'))
    varsarray = vars;
    vars = cell(1,numel(varsarray));
    for i=1:numel(varsarray)
      idx.type = '()';  idx.subs = {i};
      vars{i} = subsref(varsarray, idx);
    end
  end

  %% abstract function
  % (If we have a concrete function, it will be passed in to expr,
  % here we just deal with the abstract function case.)
  if (ischar (expr))
    tok = mystrsplit(expr, {'(', ')', ','});
    fname = strtrim(tok{1});
    assert (isvarname (fname))

    cmd = sprintf( ['_f = sp.Function("%s")(*_ins)\n' ...
                    'return (_f,)' ], fname);

    expr = python_cmd (cmd, vars{:});
  end

  % sanity check and allows symfun(10, x)
  expr = sym(expr);

  assert (isa (vars, 'cell'))
  for i=1:length(vars)
    assert (isa (vars{i}, 'sym'))
  end

  f.vars = vars;
  f = class(f, 'symfun', expr);
  superiorto ('sym');

end


%!test
%! syms x y
%! syms f(x)
%! assert(isa(f,'symfun'))
%! clear f
%! f(x,y) = sym('f(x,y)');
%! assert(isa(f,'symfun'))

%!test
%! % symfuns are syms as well
%! syms x
%! f(x) = 2*x;
%! assert (isa (f, 'symfun'))
%! assert (isa (f, 'sym'))
%! assert (isequal (f(3), 6))
%! assert (isequal (f(sin(x)), 2*sin(x)))

%!test
%! syms x y
%! f = symfun('f', {x});
%! assert(isa(f, 'symfun'))
%! f = symfun('f', [x y]);
%! assert(isa(f, 'symfun'))
%! f = symfun('f', {x y});
%! assert(isa(f, 'symfun'))

%!test
%! %% rhs is not sym
%! syms x
%! f = symfun(8, x);
%! assert(isa(f,'symfun'))
%! assert(f(10) == sym(8))

%!test
%! % vector symfun
%! syms x y
%! F(x,y) = [1; 2*x; y; y*sin(x)];
%! assert (isa (F, 'symfun'))
%! assert (isa (F, 'sym'))
%! assert (isequal (F(sym(pi)/2,4) , [sym(1); sym(pi); 4; 4] ))

%!test
%! x = sym('x');
%! y = sym('y');
%! f(x) = sym('f(x)');
%! g(x,y) = sym('g(x,y)');
%! % make sure these don't fail
%! f(1);
%! g(1,2);
%! g(x,y);
%! diff(g, x);
%! diff(g, y);

%!test
%! % defining 1D symfun in terms of a 2D symfun
%! syms x y t
%! syms 'g(x,y)'
%! f(t) = g(t,t);
%! f(5);
%! assert (length(f.vars) == 1)
%! assert (isequal( diff(f,x), sym(0)))

%!test
%! % replace g with shorter and specific fcn
%! syms x g(x)
%! g;
%! g(x) = 2*x;
%! assert( isequal (g(5), 10))

%!test
%! % octave <= 3.8 needs quotes on 2D symfuns, so make sure it works
%! syms x y
%! syms 'f(x)'
%! syms 'g(x,y)'
%! assert (isa (f, 'symfun'))
%! assert (isa (g, 'symfun'))

%!test
%! % Bug #41: Octave <= 3.8 parser fails without quotes around 2D fcn
%! % (put inside eval to hide from 3.6 parser)
%! if exist('octave_config_info', 'builtin');
%!   if (compare_versions (OCTAVE_VERSION (), '4.0.0', '>='))
%!     syms x y
%!     eval('syms g(x,y)')
%!     assert (isa (g, 'symfun'))
%!   end
%! else  % matlab
%!   syms x y
%!   eval('syms g(x,y)')
%!   assert (isa (g, 'symfun'))
%! end

%!test
%! % syms f(x) without defining x
%! clear
%! syms f(x)
%! assert(isa(f, 'symfun'))
%! assert(isa(x, 'sym'))

%%!test
%%! % FIXME: Bug #40: ops on symfuns return pure syms
%%! syms x y
%%! f(x) = x^2;
%%! g(x,y) = sym('g(x,y)')
%%! f2 = 2*f;
%%! assert( isequal (f2(4), 32))
%%! assert( isa(f2, 'symfun'))
%%! assert( isa(2*g, 'symfun'))
%%! assert( isa(0*g, 'symfun'))  % in SMT, this is the zero symfun
