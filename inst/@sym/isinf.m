%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @deftypefn {Function File}  {@var{r} =} isinf (@var{x})
%% Return true if a symbolic expression is infinite.
%%
%% FIXME: Sympy returns "none" for isinf(x + oo), perhaps we should
%% say "I don't know" in some cases too.  SMT seems to always decide...
%%
%% @seealso{isnan, double}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = isinf(x)

  if (nargin ~= 1)
    print_usage ();
  end

  % When we drop 0.7.5 support:
  %r = uniop_bool_helper(x, 'lambda a: a.is_infinite');

  sf = { 'def sf(x):'
         '    if Version(spver) < Version("0.7.6"):'
         '        return x.is_unbounded'
         '    else:'
         '        return x.is_infinite' };

  r = uniop_bool_helper(x, sf);

end


%!shared x,zoo,oo,snan
%! oo = sym(inf);
%! zoo = sym('zoo');
%! x = sym('x');
%! snan = sym(nan);

%!test
%! % various ops that give inf and nan
%! assert (isinf(oo))
%! assert (isinf(zoo))
%! assert (isinf(oo+oo))
%! assert (~isinf(oo+zoo))
%! assert (~isinf(0*oo))
%! assert (~isinf(0*zoo))
%! assert (~isinf(snan))
%! assert (~isinf(oo-oo))
%! assert (~isinf(oo-zoo))

%!test
%! % arrays
%! assert (isequal(  isinf([oo zoo]), [1 1]  ))
%! assert (isequal(  isinf([oo 1]),   [1 0]  ))
%! assert (isequal(  isinf([10 zoo]), [0 1]  ))
%! assert (isequal(  isinf([x oo x]), [0 1 0]  ))

%!test
%! % Must not contain string 'symbol'; these all should make an
%! % actual infinity.  Actually a ctor test, not isinf.
%! % IIRC, SMT in Matlab 2013b fails.
%! oo = sym(inf);
%! assert (isempty( strfind(oo.pickle, 'Symbol') ))
%! oo = sym(-inf);
%! assert (isempty( strfind(oo.pickle, 'Symbol') ))
%! oo = sym('inf');
%! assert (isempty( strfind(oo.pickle, 'Symbol') ))
%! oo = sym('-inf');
%! assert (isempty( strfind(oo.pickle, 'Symbol') ))
%! oo = sym('Inf');
%! assert (isempty( strfind(oo.pickle, 'Symbol') ))
%! oo = sym('INF');
%! assert (isempty( strfind(oo.pickle, 'Symbol') ))

%!test
%! % ops with infinity shouldn't collapse
%! syms x oo zoo
%! y = x + oo;
%! assert(~isempty( strfind(lower(y.pickle), 'add') ))
%! y = x - oo;
%! assert(~isempty( strfind(lower(y.pickle), 'add') ))
%! y = x - zoo;
%! assert(~isempty( strfind(lower(y.pickle), 'add') ))
%! y = x*oo;
%! assert(~isempty( strfind(lower(y.pickle), 'mul') ))

%!test
%! % ops with infinity are not necessarily infinite
%! syms x oo zoo
%! y = x + oo;
%! assert(~isinf(y))  %  SMT 2014a says "true", I disagree
%! y = x - zoo;
%! assert(~isinf(y))
%! y = x*oo;
%! assert(~isinf(y))
