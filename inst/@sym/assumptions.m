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
%% @deftypefn  {Function File} {@var{A} =} assumptions ()
%% @deftypefnx {Function File} {@var{A} =} assumptions (@var{x})
%% List assumptions on symbolic variables.
%%
%% The assumptions are turned as a cell-array of strings.
%%
%% FIXME: could also have a flag to return the assumption
%% dictionaries.
%%
%% @seealso{assume, sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function A = assumptions(F)

  if (nargin == 1)
    cmd = [ ...
    'x = _ins[0]\n'...
    '# saved cases to abbreviate later\n'...
    'asm_default = {"commutative":True}\n'...
    'asm_real = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "real":True}\n'...
    'asm_pos = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "negative":False, "nonnegative":True, "nonpositive":False, "nonzero":True, "positive":True, "real":True, "zero":False}\n'...
    'asm = x.assumptions0\n'...
    'if asm == asm_default:\n'...
    '    xtra = ""\n'...
    'elif asm == asm_real:\n'...
    '    #xtra = {"real":True}\n'...
    '    xtra = "real"\n'...
    'elif asm == asm_pos:\n'...
    '    xtra = "positive"\n'...
    'else:\n'...
    '    xtra = str(asm)\n'...
    '    xtra = xtra.replace("True","1").replace("False","0").replace(": ",":")\n'...
    '#xtra = str(x) + ": " + xtra\n'...
    '#return (xtra,asm)\n'...
    'return (xtra,)\n'...
    ];
    s = findsymbols(F);
    c = 0; A = {};
    for i=1:length(s)
      x = s{i};
      %[astr,adict] = python_cmd(cmd, x);
      astr = python_cmd(cmd, x);
      if ~isempty(astr)
        str = deblank([disp(x) ': ' disp(astr)]);
        c = c + 1;
        A{c} = str;
        %if c == 1
        %  A = str;
        %elseif c == 2
        %  A = {A str};
        %else
        %  A{c} = str;
        %end
      end
    end
    return
  end

  %% no input arguments
  % find all syms, check each
  alls = {}; c = 0;
  S = evalin('caller', 'whos');
  for i = 1:numel(S)
    if strcmp(S(i).class, 'sym')
      v=evalin('caller', S(i).name);
      t = findsymbols(v);
      alls(end+1:end+length(t)) = t(:);
    elseif strcmp(S(i).class, 'symfun')
      warning('FIXME: need to do anything special for symfun vars?')
      v=evalin('caller', S(i).name);
      t = findsymbols(v);
      alls(end+1:end+length(t)) = t(:);
    end
  end
  alls = [alls{:}];
  % de-dupe: could call unique if we had that overloaded
  alls = findsymbols (alls);
  alls = [alls{:}];
  A = assumptions (alls);

end


%!test
%! syms x
%! assert(isempty(assumptions(x)))
%!test
%! x = sym('x', 'positive');
%! a = assumptions(x);
%! assert(strfind(a{1}, 'positive'))
%!test
%! syms x positive
%! syms y real
%! syms z
%! f = x*y*z;
%! a = assumptions(f);
%! assert(length(a) == 2)
%! assert(strfind(a{1}, 'positive'))
%! assert(strfind(a{2}, 'real'))
