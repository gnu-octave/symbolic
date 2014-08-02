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
%% @deftypefn  {Function File} {@var{g} =} taylor (@var{f})
%% @deftypefnx {Function File} {@var{g} =} taylor (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} taylor (@var{f}, @var{x}, @var{a})
%% @deftypefnx {Function File} {@var{g} =} taylor (..., @var{key}, @var{value})
%% Symbolic Taylor series.
%%
%% If omitted, @var{x} is chosen with @code{symvar} and @var{a}
%% defaults to zero.
%%
%% Key/value pairs can be used to set the order:
%% @example
%% syms x
%% f = exp(x)
%% taylor(f,x,0,'order',6)
%% @end example
%% One can also set 'expansionPoint' instead of passing @var{a}.
%%
%% @seealso{diff}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, differentiation

function s = taylor(f,varargin)

  if (nargin == 1)  % taylor(f)
    x = symvar(f,1);
    a = sym(0);
    i = 1;
  elseif (nargin == 2)  % taylor(f,x)
    x = varargin{1};
    a = sym(0);
    i = 2;
  elseif (~ischar(varargin{1}) && ~ischar(varargin{2}))
    % taylor(f,x,a,...)
    x = varargin{1};
    a = varargin{2};
    i = 3;
  elseif (~ischar(varargin{1}) && ischar(varargin{2}))
    % taylor(f,x,'param')
    x = varargin{1};
    a = sym(0);
    i = 2;
  else  % taylor(f,'param')
    assert (ischar(varargin{1}))
    x = symvar(f,1);
    a = sym(0);
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

  if (numel(x) >= 1)
    warning('FIXME: Issue #31 multivar Taylor expansions not implemented')
  end

  cmd = [ '(f,x,a,n) = _ins\n'  ...
          's = f.series(x,a,n).removeO()\n'  ...
          'return (s,)' ];
  s = python_cmd(cmd, sym(f), sym(x), sym(a), n);

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
%! % expansion point
%! syms x a
%! f = x^2;
%! g = taylor(f,x,2);
%! assert (isequal (simplify(g), f))
%! assert (isequal (g, 4*x+(x-2)^2-4))
%! g = taylor(f,x,a);
%! assert (isequal (simplify(g), f))

