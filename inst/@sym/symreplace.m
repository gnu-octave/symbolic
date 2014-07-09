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
%% @deftypefn  {Function File} {} symreplace (@var{newx})
%% @deftypefnx {Function File} {} symreplace (@var{oldx}, @var{newx})
%% @deftypefnx {Function File} {} symreplace (@var{oldx}, @var{newx}, @var{context})
%% Replace symbols in all symbolic expressions.
%%
%% Search expressions in the callers workspace for variables with
%% same name as @var{oldx} and substitutes @var{newx}.
%% If @var{oldx} is omitted, @var{newx} is used instead.
%%
%% Note: operates on the caller's workspace via evalin/assignin.
%% So if you call this from other functions, it will operate in
%% your function's workspace (not the @code{base} workspace).
%% You can pass @code{'base'} to @var{context} to operate in
%% the base context instead.
%%
%% @seealso{assume, assumeAlso, assumptions, sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function symreplace(oldx, newx, context)

  if (nargin < 3)
    context = 'caller';
  end
  if (nargin == 1)
    newx = oldx;
  end

  assert(strcmp(context, 'caller') || strcmp(context, 'base'))

  xstr = strtrim(disp(oldx));

  % ---------------------------------------------
  % Muck around in the caller's namespace, replacing syms
  % that match 'xstr' (a string) with the 'newx' sym.
  %newx =
  %xstr =
  %contect='caller';
  % alt implementation w/ script
  % ---------------------------------------------
  %assignin(context, 'hack__newx__', newx);
  %assignin(context, 'hack__xstr__', xstr);
  %evalin(context, 'fix_assumptions_script');
  S = evalin(context, 'whos');
  evalin(context, '[];');  % clear 'ans'
  for i = 1:numel(S)
    obj = evalin(context, S(i).name);
    [flag, newobj] = fix_assumptions(obj, newx, xstr);
    if flag, assignin(context, S(i).name, newobj); end
  end
  % ---------------------------------------------
end


%!test
%! % start with assumptions on x then remove them
%! syms x positive
%! f = x*10;
%! symreplace(x, sym('x'))
%! assert(isempty(assumptions(x)))

%!test
%! % replace x with y
%! syms x
%! f = x*10;
%! symreplace(x, sym('y'))
%! assert( isequal (f, 10*sym('y')))

%!test
%! % gets inside structs
%! syms x
%! f = {x 1 2 {3 4*x}};
%! symreplace(x, sym('y'))
%! syms y
%! assert( isequal (f{1}, y))
%! assert( isequal (f{4}{2}, 4*y))
