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
%% @deftypefn {Function File} {@var{g} =} diff (@var{f})
%% @deftypefnx {Function File} {@var{g} =} diff (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} diff (@var{f}, ...)
%% Symbolic differentiation.
%%
%% Examples:
%% @example
%% syms x
%% f = sqrt(sin(x/2))
%% diff(f)
%% diff(f,x)
%% diff(f,x,x,x)
%% @end example
%%
%% Partial differentiation:
%% @example
%% syms x y
%% f = cos(2*x + 3*y)
%% diff(f,x,y,x);
%% diff(f,x,2,y,3);
%% @end example
%%
%% Other examples:
%% @example
%% diff(sym(1))
%% @end example
%%
%% @seealso{int}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, differentiation

function z = diff(f, varargin)

  % simpler version, but gives error on differentiating a constant
  %cmd = 'return sp.diff(*_ins),';

  % FIXME: with a sympy symvar we could move most/all of this to python?

  if ~(isscalar(f))
    z = f;
    for j = 1:numel(f)
      idx.type = '()';
      idx.subs = {j};
      % z(j) = diff(f(j), varargin{:});
      temp = diff(subsref(f, idx), varargin{:});
      z = subsasgn(z, idx, temp);
    end
    return
  end

  % two special cases for SMT compat.
  if (nargin >=2)
    q = varargin{1};
    isnum2 = isnumeric(q) || (isa(q, 'sym') && strncmpi(q.pickle, 'Integer', 7));
    if ((nargin == 2) && isnum2)
      x = symvar(f,1);
      z = diff(f, x, varargin{1});
      return
    end
    if ((nargin == 3) && isnum2)
      z = diff(f, varargin{2}, varargin{1});
      return
    end
  end


  cmd = [ '# special case for one-arg constant\n'             ...
          'if (len(_ins)==1 and _ins[0].is_constant()):\n'    ...
          '    return (sp.numbers.Zero(),)\n'                 ...
          'd = sp.diff(*_ins)\n'                              ...
          'return (d,)' ];

  varargin = sym(varargin);
  z = python_cmd (cmd, sym(f), varargin{:});

end


%!shared x,y,z
%! syms x y z

%!assert(logical( diff(sin(x)) - cos(x) == 0 ))
%!assert(logical( diff(sin(x),x) - cos(x) == 0 ))
%!assert(logical( diff(sin(x),x,x) + sin(x) == 0 ))

%! % these fail when doubles are not converted to sym
%!assert(logical( diff(sin(x),x,2) + sin(x) == 0 ))
%!assert(logical( diff(sym(1),x) == 0 ))
%!assert(logical( diff(1,x) == 0 ))
%!assert(logical( diff(pi,x) == 0 ))

%! % symbolic diff of const (w/o variable) fails in sympy, but we work around
%!assert(logical( diff(sym(1)) == 0 ))

%! % octave's vector difference still works
%!assert(isempty(diff(1)))
%!assert((diff([2 6]) == 4))

%!test
%! % other forms
%! f = sin(x);
%! g = diff(f,x,2);
%! assert (isequal (diff(f,2), g))
%! assert (isequal (diff(f,2,x), g))
%! assert (isequal (diff(f,sym(2)), g))
%! assert (isequal (diff(f,sym(2),x), g))
%! g = diff(f,x);
%! assert (isequal (diff(f), g))
%! assert (isequal (diff(f,1), g))
%! assert (isequal (diff(f,1,x), g))

%!test
%! % matrix
%! A = [x sin(x); x*y 10];
%! B = [1 cos(x); y 0];
%! assert(isequal(diff(A,x),B))
