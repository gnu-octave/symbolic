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
%% @deftypefn  {Function File} {@var{g} =} matlabFunction (@var{f})
%% @deftypefnx {Function File} {@var{g} =} matlabFunction (@var{f1}, ..., @var{fn})
%% @deftypefnx {Function File} {@var{g} =} matlabFunction (..., @var{param}, @var{value})
%% @deftypefnx {Function File} {@var{g} =} matlabFunction (..., 'vars', [@var{x} ... @var{z}])
%% @deftypefnx {Function File} {...} matlabFunction (..., 'file', @var{name})
%% @deftypefnx {Function File} {...} matlabFunction (..., 'outputs', [@var{o1} ... @var{on}])
%% Convert symbolic expression into a standard function.
%%
%% This can make anonymous functions from symbolic expressions:
%% @example
%% syms x y
%% f = x^2 + sin(y)
%% h = matlabFunction(f)
%% % output: h = @@(x,y) x.^2 + sin(y)
%% @end example
%% The order and number of inputs can be specified:
%% @example
%% syms x y
%% f = x^2 + sin(y)
%% h = matlabFunction(f, 'vars', [z y x])
%% % output: h = @@(z,y,x) x.^2 + sin(y)
%% @end example
%%
%% The name @code{matlabFunction} is for compatibility with the
%% Symbolic Math Toolbox in Matlab.
%%
%% FIXME: We can also generate an @code{.m} file, although this is not
%% implemented yet.  Relatedly, naming outputs with @var{PARAM} as
%% 'outputs' not implemented.
%%
%% FIXME: for now, only scalar sym are supported, row vectors
%% probably work, but column vectors and matrices definitely do
%% not.  Could be fixed as part of the next point.
%%
%% FIXME: this only works for very simple expressions where the
%% sympy function name is the same as the Octave one.  Polynomials
%% and trig functions are ok.  A more thorough implementation
%% involves adding Octave code generation to Sympy.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function f = matlabFunction(varargin)

  [flg, meh] = codegen(varargin{:}, 'lang', 'octave');
  assert(flg == -1);
  [Nin, inputstr, Nout, param] = deal(meh{:});


  %% Outputs
  exprstrs = {};
  for i=1:Nout
    expr = varargin{i};
    % FIXME: more work here for Abs, etc, need proper sympy codegen
    exprstr{i} = strtrim(disp(expr));
    % FIXME: ** to ^, vectorize?
    exprstr{i} = vectorize(exprstr{i});
  end

  if (Nout == 1)
    f = eval(sprintf('@(%s) %s', inputstr, exprstr{1}));
  else
    str = [ sprintf('@(%s) deal(', inputstr) ...
            sprintf('%s,', exprstr{:})];
    str = [str(1:end-1) ')'];
    f = eval(str);
  end

  % Note: this fails in Matlab SMT too, so no need to live outside @sym
  %h = matlabFunction({x,y,z},'vars',{x y z})
end


%!shared x,y,z
%! syms x y z

%!test
%! % basic test
%! h = matlabFunction(2*x);
%! assert(h(3)==6)

%!test
%! % autodetect inputs
%! h = matlabFunction(2*x*y, x+y);
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % specified inputs
%! h = matlabFunction(2*x*y, 'vars', [x y]);
%! assert(h(3,5)==30)
%! h = matlabFunction(2*x*y, x+y, 'vars', [x y]);
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays for vars list
%! h = matlabFunction(2*x*y, x+y, 'vars', {x y});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)
%! h = matlabFunction(2*x*y, x+y, 'vars', {'x' 'y'});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays specfies order, overriding symvar order
%! h = matlabFunction(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = matlabFunction(x*y, 12/y, 'vars', [y x]);
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!test
%! % cell arrays specfies order, overriding symvar order
%! h = matlabFunction(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = matlabFunction(x*y, 12/y, 'vars', [y x]);
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%%!xtest
%%! % FIXME: functions with different names in Sympy (disabled for now)
%%! f = abs(x);  % becomes Abs(x)
%%! h = matlabFunction(f);
%%! assert(h(-10) == 10)

%%!xtest
%%! % FIXME: non-scalar outputs (disabled for now)
%%! H = [x y z];
%%! M = [x y; z 16];
%%! V = [x;y;z];
%%! h = matlabFunction(H, M, V);
%%! [t1,t2,t3] = h(1,2,3);
%%! assert(isequal(t1, [1 2 3]))
%%! assert(isequal(t2, [1 2; 3 16]))
%%! assert(isequal(t3, [1;2;3]))
