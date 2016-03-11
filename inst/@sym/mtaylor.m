%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{g} =} mtaylor (@var{f})
%% @deftypefnx {Function File} {@var{g} =} mtaylor (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} mtaylor (@var{f}, @var{x}, @var{a})
%% @deftypefnx {Function File} {@var{g} =} mtaylor (@dots{}, @var{key}, @var{value})
%% Symbolic Two dimesional  Taylor series.
%%
%% If omitted, @var{x} is chosen with @code{symvar} and @var{a}
%% defaults to zero.
%%
%% Key/value pairs can be used to set the order:
%% @example
%% @group
%% >> syms x y 
%% >> f = exp(x*y);
%% >> mtaylor(f, [x,y] , [0,0], 'order', 6)
%%    @result{}  (sym)
%%                   2  2          
%%                  x ⋅y           
%%                  ───── + x⋅y + 1
%%                    2            
%% @end group
%% @end example
%%
%% As an alternative to passing @var{a}), you can also set the
%% expansion point using a key/value notation:
%% @example
%% @group
%% >> syms x
%% >> f = exp(x);
%% >> mtaylor(f, 'expansionPoint', 1, 'order', 4)
%%    @result{} (sym)
%%                   3            2
%%          ℯ⋅(x - 1)    ℯ⋅(x - 1)
%%          ────────── + ────────── + ℯ⋅(x - 1) + ℯ
%%              6            2
%% @end group
%% @end example
%% @seealso{diff}
%% @end deftypefn

%% Author: Utkarsh Gautam
%% Keywords: symbolic, differentiation , multivar

function s = mtaylor(f, varargin)

  if (nargin == 1)  % mtaylor(f)
    x = symvar(f);
    a = zeros(1,columns(x));
    i = nargin;
  elseif (nargin == 2)  % mtaylor(f,[x,y])
    x = varargin{1};  
    a = zeros(1,columns(x));
    i = nargin;
  elseif (~ischar(varargin{1}) && ~ischar(varargin{2}) && (nargin<=3) )
    % mtaylor(f,[x,y],[a,b],...)
    x = varargin{1};
    a = varargin{2};
    i = nargin;
  elseif (~ischar(varargin{1}) && ischar(varargin{2}))
    % mtaylor(f,[x,y],'param')
    x = varargin{1};
    a = zeros(1,columns(x));
    i = 2;
  elseif (~ischar(varargin{1}) && ~ischar(varargin{2}) && ischar(varargin{3}) )
    % mtaylor(f,[x,y],[a,b],'param')
    x = varargin{1};
    a = varargin{2};
    i = 3;  
  else  % mtaylor(f,'param')
    assert (ischar(varargin{1}))
    x = symvar(f);
    a = zeros(1,columns(x));
    i = 1;
  end
  %x

  n=6; %default order
  %sym(x)
  %n = 6;  %default order


  % if ~( rows(x)==1 && columns(x)==2)
  %   error('invalid input variables .Function Only for 2D expansion') %%chage this afterwards
  % end 

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
  %n
  %a
  if (numel(x) == 2)
    %error('Only two dimensional variables are supported')  
    cmd ={'(f, x, a, n) = _ins'
      'import math as ms'
      'expr=f'
      'var=x'
      'i=a'
      'expn=expr.subs([(var[x],i[x]) for x in range(len(var))]) # first constant term'
      'for x in range(1,n,1) :'
      '    bin=[binomial(x,m) for m in range(x+1)] #binomila constands'
      '    x1=x'
      '    x2=0'
      '    fact=ms.factorial(x)'
      '    for y in bin:'
      '        fterm=diff(diff(expr,var[0],x1),var[1],x2).subs([(var[x],i[x]) for x in range(len(var))])'
      '        expn=expn + y*(1.0/fact)*fterm*((var[0]-i[0])**x1)*((var[1]-i[1])**x2)'
      '        x1=x1-1'
      '        x2=x2+1'
      'return nsimplify((expn))'     
  };
  elseif (numel(x)==1 )
    cmd = { '(f, x, a, n) = _ins'
        's = f.series(x, a, n).removeO()'
        'return s,' }; 
  else
    cmd={
      '(f, x, a, n) = _ins'
      'import math as ms'
      'var=x'
      's=f'
      'for m in range(len(var)):'
      '    s=s.series(var[m],a[m],int(n)).removeO()'
      
      'return s'
    };
           
  end


  s = python_cmd (cmd, sym(f), sym(x), sym(a), n);

end


%!test
%! syms x
%! f = exp(x);
%! expected = 1 + x + x^2/2 + x^3/6 + x^4/24 + x^5/120;
%! assert (isAlways(mtaylor(f)== expected))
%! assert (isAlways(mtaylor(f,x)== expected))
%! assert (isAlways(mtaylor(f,x,0)== expected))

%!test
%! syms x y
%! f = exp(x)+exp(y);
%! expected = 2 + x + x^2/2 + x^3/6 + x^4/24 + y + y^2/2 + y^3/6 + y^4/24;
%! assert (isAlways(mtaylor(f,'order',5)== expected))
%! assert (isAlways(mtaylor(f,[x,y],'order',5)== expected))
%! assert (isAlways(mtaylor(f,[x,y],[0,0],'order',5) == expected))

%!test
%! syms x y
%! f = exp(x**2+y**2);
%! expected = 1+ x^2 +y^2 + x^4/2 + x^2*y^2 + y^4/2;
%! assert (isAlways(mtaylor(f,'order',5)== expected))
%! assert (isAlways(mtaylor(f,[x,y],'order',5)== expected))
%! assert (isAlways(mtaylor(f,[x,y],'expansionPoint', [0,0],'order',5) == expected))


%!test
%! syms x y
%! f = sqrt(1+x^2+y^2);
%! expected = 1+ x^2/2 +y^2/2 - x^4/8 - x^2*y^2/4 - y^4/8;
%! assert (isAlways(mtaylor(f,'order',6)== expected))
%! assert (isAlways(mtaylor(f,[x,y],'order',6)== expected))
%! assert (isAlways(mtaylor(f,[x,y],'expansionPoint', [0,0],'order',5) == expected))


%!test
%! syms x y
%! f = sin(x**2+y**2);
%! expected = sin(sym(1))+2*cos(sym(1))*(x-1)+(cos(sym(1))-2*sin(sym(1)))*(x-1)^2 + cos(sym(1))*y^2;
%! assert (isAlways(mtaylor(f,[x,y],'expansionPoint', [1,0],'order',3) == expected))

%!test
%! % key/value ordering doesn't matter
%! syms x y
%! f = exp(x+y);
%! g1 = mtaylor(f, 'expansionPoint', [1,1], 'order', 3);
%! g2 = mtaylor(f, 'order', 3, 'expansionPoint', [1,1]);
%! assert (isAlways(g1== g2))

%!test
%! syms x y
%! f = x**2 +y**2;
%! assert (isAlways(mtaylor(f,[x,y],[0,0],'order',0)== sym(0) ))
%! assert (isAlways(mtaylor(f,[x,y],[0,0],'order',1)== sym(0) ))
%! assert (isAlways(mtaylor(f,[x,y],[0,0],'order',2)== sym(0) ))
%! assert (isAlways(mtaylor(f,[x,y],[0,0],'order',3)== sym(x**2+y**2)))
%! assert (isAlways(mtaylor(f,[x,y],[0,0],'order',4)== sym(x**2+y**2)))

%!test
%! % syms for a and order
%! syms x y
%! f = x^2;
%! assert (isAlways(mtaylor(f,x,sym(0),'order',sym(2))== 0))
%! assert (isAlways(mtaylor(f,x,sym(0),'order',sym(4))== x^2))

%!test
%! % expansion point
%! syms x a
%! f = x^2;
%! g = mtaylor(f,x,2);
%! assert (isAlways(simplify(g)== f))
%! assert (isAlways(g== 4*x+(x-2)^2-4))
%! g = mtaylor(f,x,a);
%! assert (isAlways(simplify(g)== f))

%!xtest
%! % wrong order-1 series with nonzero expansion pt:
%! % upstream bug https://github.com/sympy/sympy/issues/9351
%! syms x
%! g = x^2 + 2*x + 3;
%! h = mtaylor (g, x, 4, 'order', 1);
%! assert (isAlways(h== 27)) ;
