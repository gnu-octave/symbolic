%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @documentencoding UTF-8
%% @deftypefun  {@var{A} =} assumptions ()
%% @deftypefunx {@var{A} =} assumptions (@var{x})
%% @deftypefunx {[@var{v}, @var{d}] =} assumptions (@var{x}, 'dict')
%% @deftypefunx {@var{L} =} assumptions ('possible')
%% List assumptions on symbolic variables.
%%
%% The assumptions are returned as a cell-array of strings:
%% @example
%% @group
%% syms x y positive
%% syms n integer
%% assumptions
%%   @result{} ans =
%%     @{
%%       [1,1] = n: integer
%%       [1,2] = x: positive
%%       [1,3] = y: positive
%%     @}
%% assumptions(n)
%%   @result{} ans =
%%     @{
%%       [1,1] = n: integer
%%     @}
%% @end group
%% @end example
%%
%% You can get the list of assumptions relevant to an expression:
%% @example
%% @group
%% f = sin(n*x);
%% assumptions(f)
%%   @result{} ans =
%%     @{
%%       [1,1] = n: integer
%%       [1,2] = x: positive
%%     @}
%% @end group
%% @end example
%%
%% With the optional second argument set to the string @code{'dict'},
%% return the assumption dictionaries in @var{d} corresponding
%% to the variables in @var{v}.
%%
%% You can also get a list of possible assumptions:
%% @example
%% @group
%% A = assumptions('possible');
%% strjoin(sort(A), ', ')
%%   @result{} ans = ..., finite, ..., positive, ..., zero
%% @end group
%% @end example
%%
%% @seealso{sym, syms, @@sym/assume, @@sym/assumeAlso}
%% @end deftypefun

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [A, B] = assumptions(F, outp)

  if ((nargin == 1) && ischar(F) && strcmp(F, 'possible'))
    A = valid_sym_assumptions();
    return
  end

  if ((nargin == 0) || isempty(F))
    find_all_free_symbols = true;
  else
    find_all_free_symbols = false;
  end
  if (nargin <= 1)
    outp = 'no';
  end

  if (find_all_free_symbols)
    %% no input arguments
    % find all syms, check each for free symbols
    workspace = {};
    context = 'caller';
    S = evalin(context, 'whos');
    evalin(context, '[];');  % clear 'ans'
    for i = 1:numel(S)
      workspace{i} = evalin(context, S(i).name);
    end
    F = findsymbols(workspace);
  end

  cmd = {
      'x = _ins[0]'
      'outputdict = _ins[1]'
      'd = x._assumptions.generator'
      'if d == {}:'
      '    astr = ""'
      'else:'
      '    astr = ", ".join(sorted([("" if v else "~") + str(k) for (k,v) in list(d.items())]))'
      'if outputdict:'
      '    return (astr, d)'
      'else:'
      '    return astr,' };

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
      [astr, adict] = pycall_sympy__ (cmd, x, true);
      if ~isempty(astr)
        c = c + 1;
        A{c} = x;
        B{c} = adict;
      end
    else
      astr = pycall_sympy__ (cmd, x, false);
      if ~isempty(astr)
        c = c + 1;
        str = [x.flat ': ' astr];
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
%! clear variables  % for matlab test script
%! syms x positive
%! assert(~isempty(assumptions()))
%! clear x
%! assert(isempty(assumptions()))

%!test
%! % make sure we have at least these possible assumptions
%! A = {'real' 'positive' 'negative' 'integer' 'even' 'odd' 'rational'};
%! B = assumptions('possible');
%! assert (isempty (setdiff(A, B)))

%!test
%! A = assumptions('possible');
%! for i = 1:length(A)
%!   x = sym('x', A{i});
%!   a = assumptions(x);
%!   assert(strcmp(a{1}, ['x: ' A{i}] ))
%!   s1 = sympy (x);
%!   s2 = ['Symbol(''x'', ' A{i} '=True)'];
%!   assert (strcmp (s1, s2))
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

%!test
%! % dict output
%! syms x positive
%! syms y real
%! syms z
%! f = x*y*z;
%! [v, d] = assumptions(f, 'dict');
%! assert(length(v) == 2)
%! assert(iscell(v))
%! assert(isa(v{1}, 'sym'))
%! assert(isa(v{2}, 'sym'))
%! assert(length(d) == 2)
%! assert(iscell(d))
%! assert(isstruct(d{1}))
%! assert(isstruct(d{2}))

%!test
%! %% assumptions on just the vars in an expression
%! clear variables  % for matlab test script
%! syms x y positive
%! f = 2*x;
%! assert(length(assumptions(f))==1)
%! assert(length(assumptions())==2)

%!test
%! %% assumptions in cell/struct
%! clear variables  % for matlab test script
%! syms x y z w positive
%! f = {2*x [1 2 y] {1, {z}}};
%! assert(length(assumptions())==4)
%! assert(length(assumptions(f))==3)
%! clear x y z w
%! assert(length(assumptions())==3)
%! assert(length(assumptions(f))==3)

%!test
%! % multiple assumptions
%! n = sym('n', 'negative', 'even');
%! assert (logical (n < 0))
%! assert (~(logical (n > 0)))
%! assert (~(logical (n == -1)))

%!test
%! % multiple assumptions: eqn neither true nor false
%! n = sym('n', 'negative', 'even');
%! assert (~isequal (n, sym(true)) && ~isequal (n, sym(false)))

%!test
%! %% TODO: rewrite later with https://github.com/cbm755/octsympy/issues/622
%! a = pycall_sympy__ ('return Symbol("a", real=False)');
%! assert (strcmp (assumptions (a), {'a: ~real'}))
