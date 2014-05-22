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
%% @deftypefnx {Function File} {[@var{v}, @var{d}] =} assumptions (@var{x}, 'dict')
%% List assumptions on symbolic variables.
%%
%% The assumptions are turned as a cell-array of strings.
%%
%% With the optional second argument set to @code{'dict'},
%% return the assumption dictionaries in @var{d} corresponding
%% to the variables in @var{v}.
%%
%% @seealso{sym, syms, assume, assumeAlso}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [A,B] = assumptions(F, outp)

  if ((nargin == 0) || isempty(F))
    find_all_free_symbols = true;
  else
    find_all_free_symbols = false;
  end
  if (nargin <= 1)
    outp = 'no';
  end
  if ((nargin >= 1) && ~isempty(F))
    assert(isa(F, 'sym'))
  end


  if (find_all_free_symbols)
    %% no input arguments
    % find all syms, check each for free symbols
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
    F = [alls{:}];
    % F probably has dups but that doesn't matter for next step
  end


  % Note: we abbreviate certain assumptions dicts to shorter
  % equivalent forms.  Probably should have some central
  % py fcn for this (FIXME: maybe SymPy has already?)
  % See also, sym.m and syms.m.
  % Could also return abbreviated dicts here?  Although that
  % is bound to cause trouble for someone....
  cmd = [ ...
    'x = _ins[0]\n'...
    'outputdict = _ins[1]\n'...
    '# saved cases to abbreviate later\n'...
    'adict_default = {"commutative":True}\n'...
    'adict_real = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "real":True}\n'...
    'adict_pos = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "negative":False, "nonnegative":True, "nonpositive":False, "nonzero":True, "positive":True, "real":True, "zero":False}\n'...
    'adict_odd = {"even":False, "nonzero":True, "commutative":True, "noninteger":False, "hermitian":True, "zero":False, "complex":True, "rational":True, "real":True, "integer":True, "imaginary":False, "odd":True, "irrational":False}\n'...
    'adict_even = {"real":True, "even":True, "commutative":True, "noninteger":False, "hermitian":True, "complex":True, "rational":True, "integer":True, "imaginary":False, "odd":False, "irrational":False}\n'...
    'adict_integer = {"real":True, "commutative":True, "noninteger":False, "hermitian":True, "complex":True, "rational":True, "integer":True, "imaginary":False, "irrational":False}\n'...
    'adict_rational = {"real":True, "commutative":True, "hermitian":True, "complex":True, "rational":True, "imaginary":False, "irrational":False}\n'...
    'adict = x.assumptions0\n'...
    'if adict == adict_default:\n'...
    '    astr = ""\n'...
    '    #adict={}\n'...
    'elif adict == adict_real:\n'...
    '    astr = "real"\n'...
    '    #adict = {"real":True}\n'...
    'elif adict == adict_pos:\n'...
    '    astr = "positive"\n'...
    '    #adict = {"positive":True}\n'...
    'elif adict == adict_integer:\n'...
    '    astr = "integer"\n'...
    '    #adict = {"integer":True}\n'...
    'elif adict == adict_even:\n'...
    '    astr = "even"\n'...
    '    #adict = {"even":True}\n'...
    'elif adict == adict_odd:\n'...
    '    astr = "odd"\n'...
    '    #adict = {"odd":True}\n'...
    'elif adict == adict_rational:\n'...
    '    astr = "rational"\n'...
    '    #adict = {"rational":True}\n'...
    'else:\n'...
    '    astr = str(adict)\n'...
    '    astr = astr.replace("True","1").replace("False","0").replace(": ",":")\n'...
    '#astr = str(x) + ": " + astr\n'...
    'if outputdict:\n'...
    '    return (astr,adict)\n'...
    'else:\n'...
    '    return (astr,)\n'...
  ];
  c = 0; A = {};
  if strcmp(outp, 'dict')
    B = {};
  end
  if (isempty(F))
    return
  end
  s = findsymbols(F);
  for i=1:length(s)
      x = s{i};
      if strcmp(outp, 'dict')
        [astr, adict] = python_cmd(cmd, x, true);
      else
        astr = python_cmd(cmd, x, false);
      end
      if ~isempty(astr)
        str = strtrim([disp(x) ': ' astr]);
        c = c + 1;
        if strcmp(outp, 'dict')
          A{c} = s;
          B{c} = adict;
        else
          A{c} = str;
        end
        %if c == 1
        %  A = str;
        %elseif c == 2
        %  A = {A str};
        %else
        %  A{c} = str;
        %end
      end
  end

end


%!test
%! syms x
%! assert(isempty(assumptions(x)))

%!test
%! x = sym('x', 'positive');
%! a = assumptions(x);
%! assert(~isempty(strfind(a{1}, 'positive')))

%!test
%! syms x
%! assert(isempty(assumptions(x)))

%!test
%! clear
%! assert(isempty(assumptions()))

%!test
%! A = {'real' 'positive' 'integer' 'even' 'odd' 'rational'};
%! for i = 1:length(A)
%!   x = sym('x', A{i});
%!   a = assumptions(x);
%!   assert(strcmp(a{1}, ['x: ' A{i}] ))
%! end

%!test
%! syms x positive
%! syms y real
%! syms z
%! f = x*y*z;
%! a = assumptions(f);
%! assert(length(a) == 2)
%! assert(~isempty(strfind(a{1}, 'positive')))
%! assert(~isempty(strfind(a{2}, 'real')))
