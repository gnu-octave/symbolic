%% Copyright (C) 2014, 2015 Colin B. Macdonald
%% Copyright (C) 2016 Utkarsh Gautam
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
%% @deftypefn  {Function File} {@var{g} =} taylor (@var{f})
%% @deftypefnx {Function File} {@var{g} =} taylor (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} taylor (@var{f}, @var{x}, @var{a})
%% @deftypefnx {Function File} {@var{g} =} taylor (@dots{}, @var{key}, @var{value})
%% Symbolic Taylor series.
%%
%% If omitted, @var{x} is chosen with @code{symvar} and @var{a}
%% defaults to zero.
%%
%% Key/value pairs can be used to set the order:
%% syms x
%% f = exp(x);
%% taylor(f, x, 0, 'order', 6)
%%   @result{} (sym)
%%      5    4    3    2
%%     x    x    x    x
%%    ─── + ── + ── + ── + x + 1
%%    120   24   6    2
%% @example
%% @group
%% syms x y
%% f = exp(x*y);
%% taylor(f, [x,y] , [0,0], 'order', 6)
%%   @result{}  (sym)
%%        2  2
%%       x ⋅y
%%       ───── + x⋅y + 1
%%         2
%% @end group
%% @end example
%%
%% As an alternative to passing @var{a}), you can also set the
%% expansion point using a key/value notation:
%% @example
%% @group
%% syms x
%% f = exp(x);
%% taylor(f, 'expansionPoint', 1, 'order', 4)
%%   @result{} (sym)
%%                3            2
%%       ℯ⋅(x - 1)    ℯ⋅(x - 1)
%%       ────────── + ────────── + ℯ⋅(x - 1) + ℯ
%%           6            2
%% @end group
%% @end example
%% @seealso{diff}
%% @end deftypefn

%% Author: Utkarsh Gautam, Colin B. Macdonald
%% Keywords: symbolic, differentiation, multivariable

function s = taylor(f, varargin)

  if (nargin == 1)  % taylor(f)
    x = symvar(f,1);
    a = sym(0);
    i = nargin;
  elseif (nargin == 2)  % taylor(f,[x,y])
    x = varargin{1};
    a = zeros(1, length(x));
    i = nargin;
  elseif (~ischar(varargin{1}) && ~ischar(varargin{2}))
    % taylor(f, x, a)
    % taylor(f, [x,y], [a,b])
    % taylor(f, [x,y], [a,b], 'param', ...)
    x = varargin{1};
    a = varargin{2};
    i = 3;
  elseif (~ischar(varargin{1}) && ischar(varargin{2}))
    % taylor(f, x, 'param', ...)
    % taylor(f, [x,y], 'param', ...)
    x = varargin{1};
    a = zeros(1, length(x));
    i = 2;
  else  % taylor(f,'param')
    assert (ischar(varargin{1}))
    x = symvar(f,1);
    a = zeros(1, length(x));
    i = 1;
  end

  n = 6;  %default order

  while (i <= (nargin-1))
    if (strcmpi(varargin{i}, 'order'))
      n = varargin{i+1};
      i = i + 2;
    elseif (strcmpi(varargin{i}, 'expansionPoint'))
      a = varargin{i+1};
      i = i + 2;
    else
      error('invalid key/value pair')
    end
  end

  if (isfloat(n))
    n = int32(n);
  end

  if (numel(x) == 1)
    cmd = { '(f, x, a, n) = _ins'
        's = f.series(x, a, n).removeO()'
        'return s,' };
  elseif (numel(x) == 2)
    cmd ={'(f, x, a, n) = _ins'
      'expr=f'
      'var=x'
      'i=a'
      'expn=expr.subs([(var[x],i[x]) for x in range(len(var))]) # first constant term'
      'for x in range(1,n,1) :'
      '    bin=[binomial(x,m) for m in range(x+1)] #binomial constants'
      '    x1=x'
      '    x2=0'
      '    fact=sp.factorial(x)'
      '    for y in bin:'
      '        fterm=diff(diff(expr,var[0],x1),var[1],x2).subs([(var[x],i[x]) for x in range(len(var))])'
      '        expn=expn + y*(S.One/fact)*fterm*((var[0]-i[0])**x1)*((var[1]-i[1])**x2)'
      '        x1=x1-1'
      '        x2=x2+1'
      'return simplify((expn))'
  };
  else
    error('Only 2d expansions supported.');
  end

  s = python_cmd (cmd, sym(f), sym(x), sym(a), n);

end


%!test
%! syms x
%! f = exp(x);
%! expected = 1 + x + x^2/2 + x^3/6 + x^4/24 + x^5/120;
%! assert (isequal (taylor(f), expected))
%! assert (isequal (taylor(f,x), expected))
%! assert (isequal (taylor(f,x,0), expected))

%!test
%! syms x
%! f = exp(x);
%! expected = 1 + x + x^2/2 + x^3/6 + x^4/24;
%! assert (isequal (taylor(f,'order',5), expected))
%! assert (isequal (taylor(f,x,'order',5), expected))
%! assert (isequal (taylor(f,x,0,'order',5), expected))

%!test
%! % key/value ordering doesn't matter
%! syms x
%! f = exp(x);
%! g1 = taylor(f, 'expansionPoint', 1, 'order', 3);
%! g2 = taylor(f, 'order', 3, 'expansionPoint', 1);
%! assert (isequal (g1, g2))

%!test
%! syms x
%! f = x^2;
%! assert (isequal (taylor(f,x,0,'order',0), 0))
%! assert (isequal (taylor(f,x,0,'order',1), 0))
%! assert (isequal (taylor(f,x,0,'order',2), 0))
%! assert (isequal (taylor(f,x,0,'order',3), x^2))
%! assert (isequal (taylor(f,x,0,'order',4), x^2))

%!test
%! syms x y
%! f = exp(x)+exp(y);
%! expected = 2 + x + x^2/2 + x^3/6 + x^4/24 + y + y^2/2 + y^3/6 + y^4/24;
%! assert (isAlways(taylor(f,[x,y],'order',5)== expected))
%! assert (isAlways(taylor(f,[x,y],[0,0],'order',5) == expected))

%!test
%! % key/value ordering doesn't matter
%! syms x
%! f = exp(x);
%! g1 = taylor(f, 'expansionPoint', 1, 'order', 3);
%! g2 = taylor(f, 'order', 3, 'expansionPoint', 1);
%! assert (isequal (g1, g2))

%!test
%! syms x
%! f = x^2;
%! assert (isequal (taylor(f,x,0,'order',0), 0))
%! assert (isequal (taylor(f,x,0,'order',1), 0))
%! assert (isequal (taylor(f,x,0,'order',2), 0))
%! assert (isequal (taylor(f,x,0,'order',3), x^2))
%! assert (isequal (taylor(f,x,0,'order',4), x^2))

%!test
%! % syms for a and order
%! syms x
%! f = x^2;
%! assert (isequal (taylor(f,x,sym(0),'order',sym(2)), 0))
%! assert (isequal (taylor(f,x,sym(0),'order',sym(4)), x^2))

%!test
%! syms x y
%! f = exp(x**2+y**2);
%! expected = 1+ x^2 +y^2 + x^4/2 + x^2*y^2 + y^4/2;
%! assert (isAlways(taylor(f,[x,y],'order',5)== expected))
%! assert (isAlways(taylor(f,[x,y],'expansionPoint', [0,0],'order',5) == expected))


%!test
%! syms x y
%! f = sqrt(1+x^2+y^2);
%! expected = 1+ x^2/2 +y^2/2 - x^4/8 - x^2*y^2/4 - y^4/8;
%! assert (isAlways(taylor(f,[x,y],'order',6)== expected))
%! assert (isAlways(taylor(f,[x,y],'expansionPoint', [0,0],'order',5) == expected))


%!test
%! syms x y
%! f = sin(x**2+y**2);
%! expected = sin(sym(1))+2*cos(sym(1))*(x-1)+(cos(sym(1))-2*sin(sym(1)))*(x-1)^2 + cos(sym(1))*y^2;
%! assert (isAlways(taylor(f,[x,y],'expansionPoint', [1,0],'order',3) == expected))

%!test
%! % key/value ordering doesn't matter
%! syms x y
%! f = exp(x+y);
%! g1 = taylor(f, 'expansionPoint',1, 'order', 3);
%! g2 = taylor(f, 'order', 3, 'expansionPoint',1);
%! assert (isAlways(g1== g2))

%!test
%! syms x y
%! f = x**2 +y**2;
%! assert (isAlways(taylor(f,[x,y],[0,0],'order',0)== sym(0) ))
%! assert (isAlways(taylor(f,[x,y],[0,0],'order',1)== sym(0) ))
%! assert (isAlways(taylor(f,[x,y],[0,0],'order',2)== sym(0) ))
%! assert (isAlways(taylor(f,[x,y],[0,0],'order',3)== sym(x**2+y**2)))
%! assert (isAlways(taylor(f,[x,y],[0,0],'order',4)== sym(x**2+y**2)))

%!test
%! % expansion point
%! syms x a
%! f = x^2;
%! g = taylor(f,x,2);
%! assert (isequal (simplify(g), f))
%! assert (isequal (g, 4*x+(x-2)^2-4))
%! g = taylor(f,x,a);
%! assert (isequal (simplify(g), f))

%!xtest
%! % wrong order-1 series with nonzero expansion pt:
%! % upstream bug https://github.com/sympy/sympy/issues/9351
%! syms x
%! g = x^2 + 2*x + 3;
%! h = taylor (g, x, 4, 'order', 1);
%! assert (isequal (h, 27))

%!error<Only 2d expansions supported.>
%! syms x y z
%! g = x^2 + 2*y + 3*z;
%! h = taylor (g, [x,y,z], 'order', 4);
%! assert (isAlways(h == 27)) ;
