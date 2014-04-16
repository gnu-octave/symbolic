%% Copyright (C) 2003 Willem J. Atsma <watsma@users.sf.net>
%%
%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3, or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied
%% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%% PURPOSE.  See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.  If not,
%% see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{vars} =} findsym (@var{f}, @var{n})
%% Find symbols in expression @var{f} and return them comma-separated in
%% string @var{vars}. The symbols are sorted in alphabetic order. If @var{n}
%% is specified, the @var{n} symbols closest to "x" are returned.
%%
%% Example:
%% @example
%% symbols
%% x     = sym ("x");
%% y     = sym ("y");
%% f     = x^2+3*x*y-y^2;
%% vars  = findsym (f);
%% vars2 = findsym (f,1);
%% @end example
%%
%% This is intended for m****b compatibility, calls findsymbols().
%% @seealso{findsymbols}
%% @end deftypefn

function VARS = findsym(F,Nout)

  symlist = findsymbols(F);
  Nlist = length(symlist);
  if Nlist==0
    %warning('No symbols were found.')
    VARS = '';
    return
  end

  if (nargin == 1)
    VARS = strtrim(disp(symlist{1}));
    for i=2:Nlist
      VARS = [VARS ',' strtrim(disp(symlist{i}))];
    end
    return
  else
    %% If Nout is specified, sort anew from x.
    symstrings = strtrim(disp(symlist{1}));
    for i=2:Nlist
      symstrings = [symstrings ; strtrim(disp(symlist{i}))];
    end

    symasc = toascii(symstrings);

    if Nlist<Nout
      warning('Asked for %d, variables, only %d found.',Nout,Nlist);
      Nout=Nlist;
    end
    symasc(:,1) = abs(toascii('x')-symasc(:,1));

    %% Sort by creating an equivalent number for each entry
    Nc = length(symasc(1,:));
    powbase=zeros(Nc,1); powbase(Nc)=1;
    for i=(Nc-1):-1:1
      powbase(i) = powbase(i+1)*128;
    end
    [xs,I]=sort(symasc*powbase);

    VARS = deblank(symstrings(I(1),:));

    for i=2:Nout
      VARS = [VARS ',' deblank(symstrings(I(i),:))];
    end

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
