%% Copyright (C) 2014-2019, 2022 Colin B. Macdonald
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
%% @deffn  Command syms
%% @deffnx Command syms @var{x}
%% @deffnx Command syms {@var{x} @var{y} @dots{}}
%% @deffnx Command syms @var{f(x)}
%% @deffnx Command syms {@var{x} @var{asm}}
%% @deffnx Command syms {@var{x} @var{asm} @var{asm2} @dots{}}
%% Create symbolic variables and symbolic functions.
%%
%% This is a convenience function.  For example:
%% @example
%% syms x y z
%% @end example
%% instead of:
%% @example
%% @group
%% x = sym('x');
%% y = sym('y');
%% z = sym('z');
%% @end group
%% @end example
%%
%% The last arguments can provide one or more assumptions (type or
%% restriction) on the variable (@pxref{sym}).
%% @example
%% @group
%% syms x y z positive
%% syms n positive even
%% @end group
%% @end example
%%
%% Symfuns represent abstract or concrete functions.  Abstract
%% symfuns can be created with @code{syms}:
%% @example
%% syms f(x)
%% @end example
%% Here @code{x} is created in the callers workspace,
%% as a @strong{side effect}.
%%
%% Called without arguments, @code{syms} displays a list of
%% all symbolic functions defined in the current workspace.
%% @example
%% @group
%% syms x y z
%% syms
%%   @print{} Symbolic variables in current scope:
%%   @print{}   x
%%   @print{}   y
%%   @print{}   z
%% @end group
%% @end example
%%
%% Using @code{syms} to create a new symbol with different assumptions
%% does not automatically replace instances of the old symbol in the
%% caller's workspace.  For example suppose we make an absolute value
%% expression:
%% @example
%% @group
%% syms x
%% f = abs (x)
%%   @result{} f = (sym) │x│
%% @end group
%% @end example
%% If we make a new positive @code{x}, @code{f} still contains the old
%% symbol:
%% @example
%% @group
%% syms x positive
%% simplify (f)
%%   @result{} (sym) │x│
%% @end group
%% @end example
%% Note: this behaviour is slightly different from Matlab's Symbolic
%% Math Toolbox, which does change existing symbols.
%% If that behaviour is desired, @pxref{@@sym/assume} which modifies
%% existing expressions in the caller's workspace:
%% @example
%% @group
%% syms x
%% assume x positive
%% f
%%   @result{} f = (sym) x
%% @end group
%% @end example
%%
%% Caution: On Matlab, you may not want to use @code{syms} within
%% functions.
%%   In particular, if you shadow a function name, you may get
%%   hard-to-track-down bugs.  For example, instead of writing
%%   @code{syms alpha} use @code{alpha = sym('alpha')} within functions.
%%   [https://www.mathworks.com/matlabcentral/newsreader/view_thread/237730]
%%
%% @seealso{sym, assume}
%% @end deffn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function syms(varargin)

  %% No inputs
  %output names of symbolic vars
  if (nargin == 0)
    S = evalin('caller', 'whos');
    disp('Symbolic variables in current scope:')
    for i=1:numel(S)
      %S(i)
      if strcmp(S(i).class, 'sym')
        disp(['  ' S(i).name])
      elseif strcmp(S(i).class, 'symfun')
        % FIXME improve display of symfun
        disp(['  ' S(i).name ' (symfun)'])
      end
    end
    return
  end



  %% Find assumptions
  valid_asm = assumptions('possible');
  last = -1;
  for n=1:nargin
    assert(ischar(varargin{n}), 'syms: expected string inputs')
    if (ismember(varargin{n}, valid_asm))
      if (last < 0)
        last = n - 1;
      end
    elseif (strcmp(varargin{n}, 'clear'))
      error ('OctSymPy:oldsyntax', ...
             'Old "syms x clear" not supported; use "assume x clear" or "assume(x, ''clear'')"')
    elseif (last > 0)
      error('syms: cannot have symbols after assumptions')
    end
  end

  if (last < 0)
    asm = {};
    exprs = varargin;
  elseif (last == 0)
    error('syms: cannot have only assumptions w/o symbols')
  else
    asm = varargin((last+1):end);
    exprs = varargin(1:last);
  end



  % loop over each input
  for i = 1:length(exprs)
    expr = exprs{i};

    % look for parenthesis: check if we're making a symfun
    if (isempty (strfind (expr, '(') ))  % no
      assert(isvarname(expr)); % help prevent malicious strings
      assignin('caller', expr, sym(expr, asm{:}))

    else  % yes, this is a symfun
      assert(isempty(asm), 'mixing symfuns and assumptions not supported')
      % regex matches: abc(x,y), f(var), f(x, y, z), f(r2d2), f( x, y )
      % should not match: Rational(2, 3), f(2br02b)
      assert(~isempty(regexp(expr, '^\w+\(\s*[A-z]\w*(,\s*[A-z]\w*)*\s*\)$')), ...
             'invalid symfun expression')

      T = regexp (expr, '^(\w+)\((.*)\)$', 'tokens');
      assert (length (T) == 1 && length (T{1}) == 2)
      name = T{1}{1};
      varnames = strtrim (strsplit (T{1}{2}, ','));

      vars = {};
      for j = 1:length (varnames)
        % is var in the workspace?
        try
          v = evalin ('caller', varnames{j});
          create = false;
        catch
          create = true;
        end
        % if var was defined, is it a symbol with the right name?
        if (~ create)
          if (~ isa (v, 'sym'))
            create = true;
          elseif (~ strcmp (v.flat, varnames{j}))
            create = true;
          end
        end
        if (create)
          v = sym (varnames{j});
          assignin ('caller', varnames{j}, v);
        end
        vars{j} = v;
      end

      cmd = { 'f, vars = _ins'
              'return Function(f)(*vars)' };
      s = pycall_sympy__ (cmd, name, vars);

      sf = symfun(s, vars);
      assignin('caller', name, sf);
    end
  end
end


%!test
%! %% assumptions
%! syms x real
%! x2 = sym('x', 'real');
%! assert (isequal (x, x2))

%!test
%! % assumptions and clearing them on a symbol
%! syms x real
%! assert (~isempty (assumptions (x)))
%! syms x
%! assert (isempty (assumptions (x)))

%!test
%! % Note SMT would clear syms in existing expressions
%! syms x real
%! f = {x {2*x} cos(x/2)};
%! assert (~isempty (assumptions (f)))
%! syms x
%! % but we do not: this would have to toggle for pure SMT compat
%! assert (~isempty (assumptions (f)))
%! % assert (isempty (assumptions (f)))

%!error <not supported>
%! syms x clear

%!error <symbols after assumptions>
%! syms x positive y

%!error <symbols after assumptions>
%! % this sometimes catches typos or errors in assumption names
%! % (if you need careful checking, use sym not syms)
%! syms x positive evne

%!error <cannot have only assumptions>
%! syms positive integer

%!test
%! % does not create a variable called positive
%! syms x positive integer
%! assert (logical(exist('x', 'var')))
%! assert (~logical(exist('positive', 'var')))

%!test
%! % Issue #885
%! syms S(x) I(x) O(x)

%!test
%! % Issue #290
%! syms FF(x)
%! syms ff(x)
%! syms Eq(x)

%!test
%! % Issue #290
%! syms beta(x)

%!test
%! syms x real
%! syms f(x)
%! assert (~ isempty (assumptions (x)))

%!test
%! syms x real
%! f(x) = symfun(sym('f(x)'), x);
%! assert (~ isempty (assumptions (x)))
%! assert (~ isempty (assumptions (argnames (f))))
