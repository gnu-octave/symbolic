%% Copyright (C) 2014-2017, 2019 Colin B. Macdonald
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
%% @defmethodx @@sym subs (@var{f})
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
%% If @var{x} is omitted, @code{symvar} is called on @var{f} to
%% determine an appropriate variable.
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
%% @end group
%% @end example
%%
%% With only one argument, @code{subs(@var{F})} will attempt to find values for
%% each symbol in @var{F} by searching the workspace:
%% @example
%% @group
%% f = x*y
%%   @result{} f = (sym) x⋅y
%% @end group
%%
%% @group
%% x = 42;
%% f
%%   @result{} f = (sym) x⋅y
%% @end group
%% @end example
%% Here assigning a numerical value to the variable @code{x} did not
%% change the expression (because symbols are not the same as variables!)
%% However, we can automatically update @code{f} by calling:
%% @example
%% @group
%% subs(f)
%%   @result{} ans = (sym) 42⋅y
%% @end group
%% @end example
%%
%% @strong{Warning}: @code{subs} cannot be easily used to substitute a
%% @code{double} matrix; it will cast @var{y} to a @code{sym}.  Instead,
%% create a ``function handle'' from the symbolic expression, which can
%% be efficiently evaluated numerically.  For example:
%% @example
%% @group
%% syms x
%% f = exp(sin(x))
%%   @result{} f = (sym)
%%
%%        sin(x)
%%       ℯ
%%
%% fh = function_handle(f)
%%   @result{} fh =
%%
%%       @@(x) exp (sin (x))
%% @end group
%%
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% @group
%% fh(linspace(0, 2*pi, 700)')
%%   @result{} ans =
%%       1.0000
%%       1.0090
%%       1.0181
%%       1.0273
%%       1.0366
%%       ...
%% @end group
%% @end example
%%
%% @strong{Note}: Mixing scalars and matrices may lead to trouble.
%% We support the case of substituting one or more symbolic matrices
%% in for symbolic scalars, within a scalar expression:
%% @example
%% @group
%% f = sin(x);
%% g = subs(f, x, [1 sym('a'); pi sym('b')])
%%   @result{} g = (sym 2×2 matrix)
%%
%%       ⎡sin(1)  sin(a)⎤
%%       ⎢              ⎥
%%       ⎣  0     sin(b)⎦
%% @end group
%% @end example
%%
%% When using multiple variables and matrix substitions, it may be
%% helpful to use cell arrays:
%% @example
%% @group
%% subs(y*sin(x), @{x, y@}, @{3, [2 sym('a')]@})
%%   @result{} ans = (sym) [2⋅sin(3)  a⋅sin(3)]  (1×2 matrix)
%% @end group
%%
%% @group
%% subs(y*sin(x), @{x, y@}, @{[2 3], [2 sym('a')]@})
%%   @result{} ans = (sym) [2⋅sin(2)  a⋅sin(3)]  (1×2 matrix)
%% @end group
%% @end example
%%
%% @strong{Caution}, multiple interdependent substitutions can be
%% ambiguous and results may depend on the order in which you
%% specify them.
%% A cautionary example:
%% @example
%% @group
%% syms y(x) A B
%% u = y + diff(y, x)
%%   @result{} u(x) = (symfun)
%%              d
%%       y(x) + ──(y(x))
%%              dx
%%
%% subs(u, @{y, diff(y, x)@}, @{A, B@})
%%   @result{} ans = (sym) A
%%
%% subs(u, @{diff(y, x), y@}, @{B, A@})
%%   @result{} ans = (sym) A + B
%% @end group
%% @end example
%%
%% Here it would be clearer to explicitly avoid the ambiguity
%% by calling @code{subs} twice:
%% @example
%% @group
%% subs(subs(u, diff(y, x), B), y, A)
%%   @result{} ans = (sym) A + B
%% @end group
%% @end example
%%
%% @seealso{@@sym/symfun}
%% @end defmethod


function g = subs(f, in, out)

  if (nargin > 3)
    print_usage ();
  end

  if (nargin == 1)
    %% take values of x from the workspace
    in = findsymbols (f);
    out = {};
    i = 1;
    while (i <= length (in))
      xstr = char (in{i});
      try
        xval = evalin ('caller', xstr);
        foundit = true;
      catch
        foundit = false;
      end
      if (foundit)
        out{i} = xval;
        i = i + 1;
      else
        in(i) = [];  % erase that input
      end
    end
    g = subs (f, in, out);
    return
  end

  if (nargin == 2)
    out = in;
    in = symvar(f, 1);
    if (isempty(in))
      in = sym('x');
    end
  end

  % ensure everything is sym
  f = sym(f);
  if (iscell (in))
    for i = 1:numel(in)
      in{i} = sym(in{i});
    end
  else
    in = sym(in);
  end
  if (iscell (out))
    for i = 1:numel(out)
      out{i} = sym(out{i});
    end
  else
    out = sym(out);
  end

  %% Simpler code for scalar x
  %if (isscalar(in) && isscalar(in) && isscalar(out))
  %  cmd = { '(f, x, y) = _ins'
  %          'return f.subs(x, y).doit(),' };
  %  g = pycall_sympy__ (cmd, sym(f), sym(in), sym(out));
  %  return
  %end

  if (~ iscell (in) && isscalar (in))
    in = {in};
  end
  if (iscell (in) && isscalar (in) && ~ iscell (out))
    out = {out};
  end

  % "zip" will silently truncate
  assert (numel (in) == 1 || numel (in) == numel (out), ...
          'subs: number of outputs must match inputs')

  cmd = {
    '(f, xx, yy) = _ins'
    'has_vec_sub = any(y.is_Matrix for y in yy)'
    'if not has_vec_sub:'
    '    sublist = list(zip(xx, yy))'
    '    g = f.subs(sublist, simultaneous=True).doit()'
    '    return g'
    '# more complicated when dealing with matrix/vector'
    'sizes = {(a.shape if a.is_Matrix else (1, 1)) for a in yy}'
    'sizes.discard((1, 1))'
    'assert len(sizes) == 1, "all substitions must be same size or scalar"'
    'g = zeros(*sizes.pop())'
    'for i in range(len(g)):'
    '    yyy = [y[i] if y.is_Matrix else y for y in yy]'
    '    sublist = list(zip(xx, yyy))'
    '    g[i] = f.subs(sublist, simultaneous=True).doit()'
    'return g'
  };

  g = pycall_sympy__ (cmd, f, in, out);

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
%! a = sym([1 2]);
%! g = subs(sin(y), {y}, {a});
%! assert (isequal (g, sin(a)))

%!test
%! % Issue #10, subbing matrices in for scalars
%! syms y
%! a = sym([1; 2]);
%! g = subs(sin(y), {y}, a);
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
%! % Issue #10, sub matrices in for two scalars
%! syms x y
%! a = [10 20 30];
%! f = x^2*y;
%! g = subs(f, {x y}, {a a+1});
%! h = a.^2.*(a+1);
%! assert (isequal (g, h))

%!test
%! % Issue #10, sub matrices in for two scalars
%! syms x y z
%! a = [10 20 30];
%! f = x^2*y;
%! g = subs(f, {x y}, {a z});
%! h = a.^2*z;
%! assert (isequal (g, h))
%! g = subs(f, {x y}, {a 6});
%! h = a.^2*6;
%! assert (isequal (g, h))

%!error <same.*or scalar>
%! syms x y
%! a = [10 20 30];
%! f = x^2*y;
%! g = subs(f, {x y}, {[10 20 30] [10 20]});

%!test
%! % two inputs
%! syms x y
%! assert (isequal (subs (2*x, 6), sym(12)))
%! assert (isequal (subs (2*x*y^2, 6), 12*y^2))
%! assert (isequal (subs (2*y, 6), sym(12)))
%! assert (isequal (subs (sym(2), 6), sym(2)))

%!test
%! % only two inputs, vector
%! syms x
%! assert (isequal (subs (2*x, [3 5]), sym([6 10])))

%!test
%! % SMT compat, subbing in vec/mat for nonexist x
%! syms x y z
%! % you might think this would be y:
%! assert (~ isequal (subs (y, x, [1 2]), y))
%! % but it gives two y's:
%! assert (isequal (subs (y, x, [1 2]), [y y]))
%! assert (isequal (subs (sym(42), [3 5]), sym([42 42])))
%! assert (isequal (subs (sym(42), x, []), sym([])))
%! assert (isequal (subs (y, {x y}, {[1 2; 3 4], 6}), sym([6 6; 6 6])))
%! assert (isequal (subs (y, {x z}, {[1 2; 3 4], 6}), [y y; y y]))

%!test
%! syms x y
%! assert (isequal (subs (sym(42), x, y), sym(42)))
%! assert (isequal (subs (sym(42), y), sym(42)))
%! assert (isequal (subs (sym(42)), sym(42)))

%!test
%! % empty lists
%! assert (isequal (subs (sym(42), {}, {}), sym(42)))
%! assert (isequal (subs (42, sym([]), sym([])), sym(42)))

%!test
%! syms x y
%! f = x*y;
%! x = 6; y = 7;
%! g = subs (f);
%! assert (isequal (g, sym (42)))
%! assert (isa (g, 'sym'))

%!test
%! syms x y
%! f = x*y;
%! x = 6;
%! g = subs (f);
%! assert (isequal (g, 6*y))

%!test
%! syms x y
%! f = x*y;
%! xsave = x;
%! x = 6;
%! g = subs (f);
%! assert (isequal (g, 6*y))
%! assert (isequal (f, xsave*y))

%!test
%! syms a x y
%! f = a*x*y;
%! a = 6;
%! clear x
%! g = subs (f);
%! syms x
%! assert (isequal (g, 6*x*y))
