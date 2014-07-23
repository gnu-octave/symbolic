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
%% @deftypefn {Function File}  {@var{r} =} isnan (@var{x})
%% Return true if a symbolic expression is Not-a-Number.
%%
%% @seealso{isinf, double}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function r = isnan(x)

  % todo: neat idea but fails for matrices
  %r = isnan (double (x, false));

  if isscalar(x)

    cmd = 'return (_ins[0] == sp.nan,)';

    r = python_cmd (cmd, x);

    if (~ islogical(r))
      error('nonboolean return from python');
    end

  else  % array
    r = logical(zeros(size(x)));
    for j = 1:numel(x)
      % Bug #17
      idx.type = '()';
      idx.subs = {j};
      r(j) = isnan(subsref(x, idx));
    end
  end

end


%!shared x,zoo,oo,snan
%! oo = sym(inf);
%! zoo = sym('zoo');
%! x = sym('x');
%! snan = sym(nan);

%!test
%! % various ops that give nan
%! assert (isnan(0*oo))
%! assert (isnan(0*zoo))
%! assert (isnan(snan))
%! assert (isnan(snan-snan))
%! assert (isnan(oo+snan))
%! assert (isnan(oo-oo))
%! assert (isnan(oo-zoo))
%! assert (isnan(oo+zoo))
%! assert (~isnan(oo))
%! assert (~isnan(zoo))
%! assert (~isnan(oo+oo))

%!test
%! % more ops give nan
%! assert(isnan(x+snan))
%! assert(isnan(x*snan))
%! assert(isnan(0*snan))
%! assert(isnan(x+nan))
%! assert(isnan(x*nan))
%! assert(isnan(sym(0)*nan))

%!test
%! % array
%! assert (isequal(  isnan([oo zoo]),    [0 0]  ))
%! assert (isequal(  isnan([10 snan]),   [0 1]  ))
%! assert (isequal(  isnan([snan snan]), [1 1]  ))
%! assert (isequal(  isnan([snan x]),    [1 0]  ))

%!test
%! % sub in to algebraic expression gives nan
%! y = x - oo;
%! y = subs(y, x, oo);
%! assert(isnan(y))

%!test
%! % Must not contain string 'symbol'; these all should make an
%! % actual infinity.  Actually a ctor test, not isnan.
%! y = sym(nan);
%! assert (isempty( strfind(y.pickle, 'Symbol') ))
%! y = sym('nan');
%! assert (isempty( strfind(y.pickle, 'Symbol') ))
%! y = sym('NaN');
%! assert (isempty( strfind(y.pickle, 'Symbol') ))
%! y = sym('NAN');
%! assert (isempty( strfind(y.pickle, 'Symbol') ))
