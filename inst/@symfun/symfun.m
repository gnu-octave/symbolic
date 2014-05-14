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
%%
%% FIXME: but currently can include @code{(x,y)}.
%% FIXME: and in fact the 2nd argument can be omitted in that case.
%% FIXME: remove this feature?
%% @example
%% x = sym('x')
%% y = sym('y')
%% f = symfun('f(x)', x)
%% g = symfun('g(x,y)', [x y])
%% f = symfun('f(x)')
%% g = symfun('g(x,y)')
%% @end example
%%
%%
%% @seealso{sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function f = symfun(expr, vars)

  if (nargin == 0)
    % octave docs say need a no-argument default for loading from files
    expr = sym(0)
    vars = sym('x')
  end

  % if the vars are in a sym array, put them in a cell array
  if ((nargin > 1) && (isa( vars, 'sym')))
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
    tok = strsplit(expr, {'(', ')', ','});
    fname = strtrim(tok{1});

    cmd = sprintf( ['_f = sp.Function("%s")(*_ins)\n' ...
                    'return (_f,)' ], fname);

    % FIXME: if arguments are not provided we create them here (why?
    % Matlab doesn't)
    if (nargin == 1)
      vars = {};  c = 0;
      for i = 2:length(tok)
        vs = strtrim(tok{i});
        if ~isempty(vs)
          c = c + 1;
          vars{c} = sym(vs);
        end
      end
    end

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
%! syms x y
%! f = symfun('f', {x});
%! assert(isa(f, 'symfun'))
%! f = symfun('f(x)', {x});
%! assert(isa(f, 'symfun'))
%! f = symfun('f(x,y)', [x y]);
%! assert(isa(f, 'symfun'))
%! f = symfun('f(x,y)', x);
%! assert(isa(f, 'symfun'))

%% no variables given
%!test
%! f = symfun('f(x)');
%! assert(isa(f,'symfun'))

%% rhs is not sym
%!test
%! syms x
%! f = symfun(8, x);
%! assert(isa(f,'symfun'))
%! assert(f(10) == sym(8))

%% syms f(x)
%% assert(isa(f,'symfun'))
