%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod  @@sym subs (@var{f}, @var{x}, @var{y})
%% @defmethodx @@sym subs (@var{f}, @var{y})
%% Replace symbols in an expression with other expressions.
%%
%% Example substituting a value for a variable:
%% @example
%% @group
%% syms x y
%% f = x*y;
%% subs(f, x, 2)
%%   @result{} ans = (sym) 2⋅y
%% @end group
%% @end example
%% If @var{x} is omitted, @code{symvar} is used on @var{f}.
%%
%% @var{x} and @var{y} can also be vectors or lists of syms to
%% replace:
%% @example
%% @group
%% subs(f, @{x y@}, @{sin(x) 16@})
%%   @result{} ans = (sym) 16⋅sin(x)
%%
%% F = [x x*y; 2*x*y y];
%% subs(F, @{x y@}, [2 sym(pi)])
%%   @result{} ans = (sym 2×2 matrix)
%%
%%       ⎡ 2   2⋅π⎤
%%       ⎢        ⎥
%%       ⎣4⋅π   π ⎦
%%
%% @end group
%% @end example
%%
%% Note: There are many possibilities that we don't support (FIXME)
%% if you start mixing scalars and matrices.  We support one simple
%% case of subbing a matrix in for a scalar in a scalar expression:
%% @example
%% @group
%% f = sin(x);
%% g = subs(f, x, [1 2; 3 4])
%%   @result{} g = (sym 2×2 matrix)
%%
%%       ⎡sin(1)  sin(2)⎤
%%       ⎢              ⎥
%%       ⎣sin(3)  sin(4)⎦
%%
%% @end group
%% @end example
%% If you want to extend support to more cases, a good place to
%% start, as of July 2014, is the Sympy Issue #2962
%% [https://github.com/sympy/sympy/issues/2962].
%%
%% @seealso{@@sym/symfun}
%% @end defmethod


function g = subs(f, in, out)

  if (nargin == 1)
    % FIXME: SMT will take values of x from the workspace in this case.
    error('subs: we do not support single-input w/ substitution from workspace')
  elseif (nargin > 3)
    print_usage ();
  end

  if (nargin == 2)
    out = in;
    in = symvar(f, 1);
    if (isempty(in))
      in = sym('x');
    end
  end

  %% special case: scalar f, scalar in, vector out
  % A workaround for Issue #10, also upstream Sympy Issue @2962
  % (github.com/sympy/sympy/issues/2962).  There are more complicated
  % cases that will also fail but this one must be pretty common.
  if (isscalar(f) && ~iscell(in) && ~iscell(out) && isscalar(in) && ~isscalar(out))
    g = sym(out);  % a symarray of same size-shape as out, whether
                   % out is sym or double
    for i = 1:numel(out)
      % f$#k Issue #17
      %g(i) = subs(f, in, sym(out(i)))
      idx.type = '()'; idx.subs = {i};
      temp = subsref(out, idx);
      temp2 = subs(f, in, temp);
      g = subsasgn(g, idx, temp2);
    end
    return
  end

  %% Simple code for scalar x
  % The more general code would work fine, but maybe this makes some
  % debugging easier, e.g., without simultaneous mode?
  if (isscalar(in) && ~iscell(in) && ~iscell(out))
    cmd = { '(f, x, y) = _ins'
            'return f.subs(x, y).doit(),' };
    g = python_cmd (cmd, sym(f), sym(in), sym(out));
    return
  end


  %% In general
  % We build a list of of pairs of substitutions.

  in = sym(in);
  out = sym(out);



  if ( (iscell(in))  ||  (numel(in) >= 2) )
    assert_same_shape(in,out)
    sublist = cell(1, numel(in));
    for i = 1:numel(in)
      % not really Bug #17, but I doubt if I'd have done it this
      % way w/o that bug.
      if (iscell(in)),  idx1.type = '{}'; else idx1.type = '()'; end
      if (iscell(out)), idx2.type = '{}'; else idx2.type = '()'; end
      idx1.subs = {i};
      idx2.subs = {i};
      sublist{i} = { subsref(in, idx1), subsref(out, idx2) };
    end

  elseif (numel(in) == 1)  % scalar, non-cell input
    assert(~iscell(out))
    % out could be an array (although this doesn't work b/c of
    % Issue #10)
    sublist = { {in, out} };

  else
    error('not a valid sort of subs input');
  end

  % simultaneous=True is important so we can do subs(f,[x y], [y x])

  cmd = { '(f, sublist) = _ins'
          'g = f.subs(sublist, simultaneous=True).doit()'
          'return g,' };

  g = python_cmd (cmd, sym(f), sublist);

end


%!error <Invalid> subs (sym(1), 2, 3, 4)

%!shared x,y,t,f
%! syms x y t
%! f = x*y;

%!test
%! assert( isequal(  subs(f, x, y),  y^2  ))
%! assert( isequal(  subs(f, y, sin(x)),  x*sin(x)  ))
%! assert( isequal(  subs(f, x, 16),  16*y  ))

%!test
%! % multiple subs w/ cells
%! assert( isequal(  subs(f, {x}, {t}),  y*t  ))
%! assert( isequal(  subs(f, {x y}, {t t}),  t*t  ))
%! assert( isequal(  subs(f, {x y}, {t 16}),  16*t  ))
%! assert( isequal(  subs(f, {x y}, {16 t}),  16*t  ))
%! assert( isequal(  subs(f, {x y}, {2 16}),  32  ))

%!test
%! % multiple subs w/ vectors
%! assert( isequal( subs(f, [x y], [t t]),  t*t  ))
%! assert( isequal( subs(f, [x y], [t 16]),  16*t  ))
%! assert( isequal( subs(f, [x y], [2 16]),  32  ))

%!test
%! % anything you can think of
%! assert( isequal( subs(f, [x y], {t t}),  t*t  ))
%! assert( isequal( subs(f, {x y}, [t t]),  t*t  ))
%! assert( isequal( subs(f, {x; y}, [t; t]),  t*t  ))

%!test
%! % sub in doubles gives sym (matches SMT 2013b)
%! % FIXME: but see
%! % http://www.mathworks.co.uk/help/symbolic/gradient.html
%! assert( isequal( subs(f, {x y}, {2 pi}), 2*sym(pi) ))
%! assert( ~isa(subs(f, {x y}, {2 pi}), 'double'))
%! assert( isa(subs(f, {x y}, {2 pi}), 'sym'))
%! assert( isa(subs(f, {x y}, {2 sym(pi)}), 'sym'))
%! assert( isa(subs(f, {x y}, {sym(2) sym(pi)}), 'sym'))


%!shared x,y,t,f,F
%! syms x y t
%! f = sin(x)*y;
%! F = [f; 2*f];

%!test
%! % need the simultaneous=True flag in SymPy (matches SMT 2013b)
%! assert( isequal( subs(f, [x t], [t 6]), y*sin(t) ))
%! assert( isequal( subs(F, [x t], [t 6]), [y*sin(t); 2*y*sin(t)] ))

%!test
%! % swap x and y (also needs simultaneous=True
%! assert( isequal( subs(f, [x y], [y x]), x*sin(y) ))

%!test
%! % but of course both x and y to t still works
%! assert( isequal( subs(f, [x y], [t t]), t*sin(t) ))

%% reset the shared variables
%!shared

%!test
%! % Issue #10, subbing matrices in for scalars
%! syms y
%! a = sym([1 2; 3 4]);
%! f = sin(y);
%! g = subs(f, y, a);
%! assert (isequal (g, sin(a)))

%!test
%! % Issue #10, subbing matrices in for scalars
%! syms y
%! a = [10 20 30];
%! f = 2*y;
%! g = subs(f, y, a);
%! assert (isequal (g, 2*a))
%! assert (isa (g, 'sym'))

%!test
%! % two inputs
%! syms x y
%! assert (isequal (subs(sym(2)*x, 6), 12))
%! assert (isequal (subs(sym(2)*x*y^2, 6), 12*y^2))
%! assert (isequal (subs(sym(2)*y, 6), 12))
%! assert (isequal (subs(sym(2), 6), 2))
