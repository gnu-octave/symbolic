%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn  {Function File} {@var{S} =} findsym (@var{expr})
%% @deftypefnx {Function File} {@var{S} =} findsym (@var{expr}, @var{n})
%% Find symbols in expression, return them as comma-separated string
%%
%% See @code{symvar}, this just concatenates its output into a
%% string.
%%
%% Example:
%% @example
%% syms y,a,b
%% vars  = findsym (f);     % outputs 'a,b,y'
%% vars2 = findsym (f,1);   % outputs 'y'
%% @end example
%%
%% @seealso{symvar, findsymbols}
%% @end deftypefn

function s = findsym(varargin)

  A = symvar(varargin{:});

  n = length(A);


  if n == 0
    s = '';
  else
    t = subsref(A, substruct('()', {1}));
    s = strtrim(disp(t));
  end

  for i=2:n
    t = subsref(A, substruct('()', {i}));
    s = [s ',' strtrim(disp(t))];
  end

end


%!assert( findsym(sym(2)), '');
%!shared x,y,f
%! x=sym('x'); y=sym('y'); f=x^2+3*x*y-y^2;
%!assert( findsym (f), 'x,y');
%!assert( findsym (f,1), 'x');
%% closest to x
%!test
%! syms x y a b c alpha xx
%! assert(findsym(b*xx*exp(alpha) + c*sin(a*y), 2), 'xx,y')
