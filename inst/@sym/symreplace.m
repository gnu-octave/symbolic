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

function varargout = symreplace(oldx, newx, caller)

  if (nargin < 3)
    caller = 'caller';
  end
  if (nargin == 1)
    newx = oldx;
  end

  assert(strcmp(caller, 'caller') || strcmp(caller, 'base'))

  xstr = strtrim(disp(oldx));

  S = evalin(caller, 'whos');
  for i = 1:numel(S)
      S(i).name
      if strcmp(S(i).class, 'sym') || strcmp(S(i).class, 'symfun')
        % idea: get the variable from the caller, check if
        % contains any symbols with the same string as x.
        v = evalin(caller, S(i).name)
        t = findsymbols(v);
        dosub = false;
        for c = 1:length(t)
          ystr = strtrim(disp(t{c}));
          if strcmp(xstr, ystr)
            dosub = true;
            break
          end
        end
        % If so, subs in the new x and replace that variable.
        if (dosub)
          newv = subs(v,t{c},newx);
          assignin(caller, S(i).name, newv);
        end
      end
      if strcmp(S(i).class, 'symfun')
        warning('FIXME: need to do anything special for symfun vars?')
      end
  end

end


%!test
%! %% start with assumptions on x then remove them
%! syms x positive
%! f = x*10;
%! symreplace(x, sym('x'))
%! assert(isempty(assumptions(x)))


%!test
%! syms x
%! f = x*10;
%! symreplace(x, sym('y'))
%! assert( isequal (f, 10*sym('y')))
