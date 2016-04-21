%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% If @code{x} does not exist in the callers workspace, it
%% is created as a @strong{side effect} in that workspace.
%%
%% Called without arguments, @code{syms} displays a list of
%% all symbolic functions defined in the current workspace.
%%
%% Caution: On Matlab, you may not want to use @code{syms} within
%% functions.
%%   In particular, if you shadow a function name, you may get
%%   hard-to-track-down bugs.  For example, instead of writing
%%   @code{syms alpha} use @code{alpha = sym('alpha')} in functions.
%%   [https://www.mathworks.com/matlabcentral/newsreader/view_thread/237730]
%%
%% @seealso{sym}
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
  doclear = false;
  for n=1:nargin
    assert(ischar(varargin{n}), 'syms: expected string inputs')
    if (ismember(varargin{n}, valid_asm))
      if (last < 0)
        last = n - 1;
      end
    elseif (strcmp(varargin{n}, 'clear'))
      doclear = true;
      if (last < 0)
        last = n - 1;
      else
        warning('syms: should not combine "clear" with other assumptions')
      end
      if (n ~= nargin)
        error('syms: "clear" should be the final argument')
      end
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
      if (doclear)
        % We do this here instead of calling sym() because sym()
        % would modify this workspace instead of the caller's.
        newx = sym(expr);
        assignin('caller', expr, newx);
        xstr = newx.flat;
        % ---------------------------------------------
        % Muck around in the caller's namespace, replacing syms
        % that match 'xstr' (a string) with the 'newx' sym.
        %xstr = x;
        %newx = s;
        context = 'caller';
        % ---------------------------------------------
        S = evalin(context, 'whos');
        evalin(context, '[];');  % clear 'ans'
        for i = 1:numel(S)
          obj = evalin(context, S(i).name);
          [newobj, flag] = symreplace(obj, xstr, newx);
          if flag, assignin(context, S(i).name, newobj); end
        end
        % ---------------------------------------------
      else
        assignin('caller', expr, sym(expr, asm{:}))
      end

    else  % yes, this is a symfun
      assert(isempty(asm), 'mixing symfuns and assumptions not supported')
      % regex matches: abc(x,y), f(var), f(x, y, z), f(r2d2), f( x, y )
      % should not match: Rational(2, 3), f(2br02b)
      assert(~isempty(regexp(expr, '^\w+\(\s*[A-z]\w*(,\s*[A-z]\w*)*\s*\)$')), ...
             'invalid symfun expression')
      s = sym(expr);
      %vars = symvar(s)  % might re-order the inputs, instead:
      cmd = { 'f = _ins[0]'
              'return (f.func.__name__, f.args)' };
      [name, vars] = python_cmd (cmd, s);
      sf = symfun(s, vars);
      assignin('caller', name, sf);
      for i = 1:length(vars)
        v = vars{i};
        assignin('caller', v.flat, v);
      end
    end
  end
end


%!test
%! %% assumptions
%! syms x real
%! x2 = sym('x', 'real');
%! assert (isequal (x, x2))

%!test
%! %% assumptions and clearing them
%! syms x real
%! f = {x {2*x}};
%! A = assumptions();
%! assert ( ~isempty(A))
%! syms x clear
%! A = assumptions();
%! assert ( isempty(A))

%!test
%! %% matlab compat, syms x clear should add x to workspace
%! syms x real
%! f = 2*x;
%! clear x
%! assert (~logical(exist('x', 'var')))
%! syms x clear
%! assert (logical(exist('x', 'var')))

%!error <symbols after assumptions>
%! syms x positive y

%!error <symbols after assumptions>
%! % this sometimes catches typos or errors in assumption names
%! % (if you need careful checking, use sym not syms)
%! syms x positive evne

%!warning <should not combine>
%! syms x positive clear

%!error <should be the final argument>
%! syms x clear y

%!error <cannot have only assumptions>
%! syms positive integer

%!test
%! % does not create a variable called positive
%! syms x positive integer
%! assert (logical(exist('x', 'var')))
%! assert (~logical(exist('positive', 'var')))
