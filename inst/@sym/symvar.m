%% Copyright (C) 2014 Colin B. Macdonald and others
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
%% @deftypefn {Function File} {@var{vars} =} symvar (@var{f})
%% @deftypefnx {Function File} {@var{vars} =} symvar (@var{f}, @var{n})
%% Find symbols in expression and return them as a symbolic vector
%%
%% The symbols are sorted in alphabetic order with capital letters
%% first.  If @var{n} is specified, the @var{n} symbols closest to
%% @code{x} are returned.
%%
%% Example:
%% @example
%% syms x,y
%% f     = x^2+3*x*y-y^2;
%% vars  = findsym (f);
%% vars2 = findsym (f,1);
%% @end example
%%
%% Compatibility with other implementations: the output should
%% match the order of the equivalent command in the Matlab Symbolic
%% Toolbox.  Their documentation (as of 2013b) says "closest to
%% @code{x} or @code{X}", but it seems to be just @code{x} (which
%% is what we implement).
%%
%% FIXME: capitalized variables are not sorted correctly in the 2nd
%% form:
%% @example
%% symvar(X*Y*Z, 2)   % returns [Z Y] instead of [X Y]
%% @end example
%%
%%
%% @seealso{findsym, findsymbols}
%% @end deftypefn

%% Author: Colin B. Macdonald, Willem J. Atsma
%% Keywords: symbolic

function vars = symvar(F, Nout)

  symlist = findsymbols (F);
  Nlist = length (symlist);

  if (nargin == 1)
    vars = sym([]);
    for i=1:Nlist
      %vars(i) = symlist{i};
      idx.type = '()'; idx.subs = {i};
      vars = subsasgn(vars, idx, symlist{i});
    end

  else
    if (Nout == 0)
      error('number of requested symbols should be positive')
    end

    %% This sorting code is written by:
    % Copyright (C) 2003 Willem J. Atsma <watsma@users.sf.net>
    % License: GPL-3

    if Nlist<Nout
      warning('Asked for %d variables, but only %d found.',Nout,Nlist);
      Nout=Nlist;
    end

    vars = sym([]);
    if (Nout == 0)
      return
    end

    %% If Nout is specified, sort anew from x.
    symstrings = strtrim(disp(symlist{1}));
    for i=2:Nlist
      symstrings = [symstrings ; strtrim(disp(symlist{i}))];
    end

    symasc = toascii(symstrings);

    symasc(:,1) = abs(toascii('x')-symasc(:,1));

    %% Sort by creating an equivalent number for each entry
    Nc = length(symasc(1,:));
    powbase=zeros(Nc,1); powbase(Nc)=1;
    for i=(Nc-1):-1:1
      powbase(i) = powbase(i+1)*128;
    end
    [xs,I]=sort(symasc*powbase);

    for i=1:Nout
      %vars(i) = symlist{i};
      idx.type = '()'; idx.subs = {i};
      vars = subsasgn(vars, idx, symlist{I(i)});
    end
  end
end


%% some corner cases
%!assert (isempty (symvar (sym(1))));
%!test
%! disp('*** One warning expected')
%! assert (isempty (symvar (sym(1),1)));
%!test
%! try
%!   symvar(sym(1),0);
%!   assert(false);
%! catch
%!   assert(true)
%! end

%!shared x,y,f
%! x=sym('x'); y=sym('y'); f=x^2+3*x*y-y^2;
%!assert (isequal (symvar (f), [x y]));
%!assert (isequal (symvar (f, 1), x));
%% closest to x
%!test
%! syms x y a b c alpha xx
%! assert (isequal (symvar (b*xx*exp(alpha) + c*sin(a*y), 2), [xx y]))

%% tests to match Matlab R2013b
%!shared x,y,z,a,b,c,X,Y,Z
%! syms x y z a b c X Y Z

%% X,Y,Z first if no 2nd argument
%!test
%! s = prod([x y z a b c X Y Z]);
%! assert (isequal( symvar (s), [X Y Z a b c x y z] ))

%% uppercase have *low* priority with argument?
%!test
%! s = prod([x y z a b c X Y Z]);
%! assert (isequal (symvar (s,4), [x, y, z, c] ))

%% closest to x
%!xtest
%! s = prod([y z a b c Y Z]);
%! assert (isequal( symvar (s,6), [ y, z, c, b, a, Y] ))
%! s = prod([a b c Y Z]);
%! assert (isequal( symvar (s,4), [ c, b, a, Y] ))

%% another broken case
%!xtest
%! s = X*Y*Z;
%! assert (isequal( symvar (s,3), [X Y Z] ))
