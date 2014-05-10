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
%% @deftypefn  {Function File} {} assumeAlso (@var{x}, @var{cond})
%% @deftypefnx {Function File} {@var}x} =} assumeAlso (@var{x}, @var{cond})
%% Add additional assumptions on a symbolic variable.
%%
%% Note: operates on the caller's workspace via evalin/assignin.
%% So if you call this from other functions, it will operate in
%% your function's  workspace (not the @code{base} workspace).
%%
%% FIXME: idea of rewriting all sym vars is a bit of a hack, not
%% well tested (for example, with global vars.)
%%
%% @seealso{assume, assumptions, sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function varargout = assumeAlso(x, cond, varargin)

  [tilde,ca] = assumptions(x, 'dict');

  if isempty(ca)
    ca = [];
  elseif (length(ca)==1)
    ca = ca{1};
  else
    ca
    error('expected at most one dict')
  end

  ca.(cond) = true;

  xstr = strtrim(disp(x));
  newx = sym(xstr, ca);


  %% tricky part
  % find other instances of x and replace them
  % with newx.
  % FIXME: may want a way to disable this, its essentially for
  % Matlab SMT compatibility.

  
  % FIXME: how to split this out to helper fcn? 'caller' would bee wrong?
  if (1==1)
    S = evalin('caller', 'whos');
    for i = 1:numel(S)
      if strcmp(S(i).class, 'sym') || strcmp(S(i).class, 'symfun')
        % idea: get the variable from the caller, check if
        % contains any symbols with the same string as x.
        v = evalin('caller', S(i).name);
        t = findsymbols(v);
        dosub = false;
        for c = 1:length(t)
          ystr = strtrim(disp(t{c}));
          if strcmp(xstr,ystr)
            dosub = true;
            break
          end
        end
        % If so, subs in the new x and replace that variable.
        if (dosub)
          newv = subs(v,t{c},newx);
          assignin('caller', S(i).name, newv);
        end
      end
      if strcmp(S(i).class, 'symfun')
        warning('FIXME: need to do anything special for symfun vars?')
      end
    end
  end

  if (nargout > 0)
    varargout{1} = newx;
  end
end


%!test
%! syms x
%! assumeAlso(x, 'positive')
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive'))

%!test
%! syms x positive
%! assumeAlso(x, 'integer')
%! [tilde,a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)
