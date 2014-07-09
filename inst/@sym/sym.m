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
%% @deftypefn  {Function File} {@var{x} =} sym (@var{y})
%% @deftypefnx {Function File} {@var{x} =} sym (...)
%% Define symbols and numbers as symbolic expressions.
%%
%% @var{y} can be an integer, a string or one of several special
%% double values.  It can also be a double matrix or a cell
%% array.
%%
%% FIXME: needs more documentation.
%%
%% Examples:
%% @example
%% x = sym ('x')
%% y = sym ('2')
%% y = sym (3)
%% y = sym (inf)
%% y = sym (pi)
%% y = sym (sym (pi))   % idempotent
%% @end example
%%
%% A second argument provides an assumption @xref{assumptions},
%% or restriction on the type of the symbol.
%% @example
%% x = sym ('x', 'positive')
%% @end example
%% The following options are supported:
%% 'real', 'positive', 'integer', 'even', 'odd', 'rational'.
%% Others are supported in SymPy but not exposed directly here.
%%
%% Caution: it is possible to create multiple variants of the
%% same symbol with different assumptions.
%% @example
%% x1 = sym('x')
%% x2 = sym('x', 'positive')
%% x1 == x2   % false
%% @end example
%%
%% @seealso{syms,assumption}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function s = sym(x, varargin)

  if (nargin == 0)
    s = sym(0);
    return
  end

  %% The actual class constructor
  % tempting to put this elsewhere (the 'private ctor') but we need
  % to access it from the python ipc stuff: outside the class.
  if (nargin > 2)
    s.pickle = x;
    s.size = varargin{1};
    s.flattext = varargin{2};
    s.text = varargin{3};
    s.extra = [];
    s = class(s, 'sym');
    return
  end

  %% User interface for defining sym
  % sym(1), sym('x'), etc.

  % not a subclass, exactly a sym, not symfun
  %if (strcmp (class (x), 'sym'))
  if (isa (x, 'sym')  &&  nargin==1)
    s = x;
    return

  elseif (iscell (x)  &&  nargin==1)
    s = cell_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isscalar (x)  &&  nargin==1)
    s = double_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isreal (x)  &&  nargin==1)
    s = sym(real(x)) + sym('I')*sym(imag(x));
    return

  elseif (isa (x, 'double')  &&  nargin==1)
    if (x == pi)
      s = sym('pi');
    elseif (isinf(x)) && (x > 0)
      s = sym('inf');
    elseif (isinf(x)) && (x < 0)
      s = sym('-inf');
    elseif (isnan(x))
      s = sym('nan');
    elseif (mod(x,1) == 0)   % is integer
      s = sym(sprintf('%d', x));
    else
      % Allow 1/3 and other "small" fractions.
      % FIXME: good if this warning were configurable, personally I like
      % it to at least warn so I can catch bugs.
      % Matlab SMT also does this (w/o warning).
      % I don't trust this behaviour much.
      warning('Using rats() for rational approx, did you really mean to pass a noninteger?');
      s = sym(rats(x));
    end
    return


  elseif (isa (x, 'char'))
    useSymbolNotS = false;
    cmd = [];

    % first check if we have assumptions
    asm = [];
    if (nargin == 2)
      asm = varargin{1};
      useSymbolNotS = true;
    end

    % check if we're making a symfun
    if (~isempty (strfind (x, '(') ))
      %% Start making an abstract symfun
      % If we see parentheses, we assume user is making a symfun.  We
      % don't do it directly here, but instead return a specially
      % tagged sym.  Essentially, the contents of this sym are
      % irrelevant except for the special contents of the "extra"
      % field.  subasgn can then note this and actually build the
      % symfun: it will know the arguments from the LHS of "g(x) =
      % sym('g(x)')".  Rather, if the user calls "g = sym('g(x)')",
      % I see no easy way to throw an error, so we just make the
      % symbol itself a plea to read the docs ;-)
      %disp('DEBUG: I hope you are using this sym for the rhs of a symfun...');
      s = sym('pleaseReadHelpSymFun');
      s.extra = {'MAKING SYMFUN HACK', x};
      %s = x;  % this would be nicer, but it fails to call subsasgn
      assert(isempty(asm))
      return
    end

    % various special cases for x
    if (strcmp(x, 'pi'))
      cmd = 'z = sp.pi';
    elseif (strcmpi(x, 'inf')) || (strcmpi(x, '+inf'))
      cmd = 'z = sp.oo';
    elseif (strcmpi(x, '-inf'))
      cmd = 'z = -sp.oo';
    elseif (strcmpi(x, 'nan'))
      cmd = 'z = sp.nan';
    elseif (strcmpi(x, 'i'))
      cmd = 'z = sp.I';
    %% Symbols with special meanings in SymPy: Issue #23
    elseif (strcmp(x, 'beta') || strcmp(x, 'gamma') || ...
            strcmp(x, 'zeta') || strcmp(x, 'Chi') || ...
            strcmp(x, 'S') || strcmp(x, 'N') || strcmp(x, 'Q'))
      useSymbolNotS = true;
    elseif (strcmp(x, 'lambda'))
      x = 'lamda';
      useSymbolNotS = true;
    elseif (strcmp(x, 'Lambda'))
      x = 'Lamda';
      useSymbolNotS = true;
    end

    if (~useSymbolNotS)
      % if we're not forcing Symbol() then we use S(), unless
      % cmd already set.
      if (isempty(cmd))
        if (~isempty(strfind(x, '.')))
          warning('possibly unintended decimal point in constructor string');
        end
        cmd = sprintf('z = sympy.S("%s")', x);
      end
    else % useSymbolNotS
      assert(isempty(cmd), 'inconsistent input')
      if isempty(asm)
        cmd = sprintf('z = sympy.Symbol("%s")', x);
      elseif isstruct(asm) && isscalar(asm)
        % we have an assumptions dict
        cmd = sprintf('s = sympy.Symbol("%s", **_ins[0])\nreturn s,', x);
        s = python_cmd (cmd, asm);
        return
      elseif strcmp(asm, 'clear')
        %% 'clear' is a special case
        newx = sym(x);
        xstr = strtrim(disp(newx));
        % --------------------------
        % Muck around in the caller's namespace, replacing syms
        % thst match 'xstr' (a string) with the 'newx' sym.
        S = evalin('caller', 'whos');
        evalin('caller', '[];');  % clear 'ans'
        for i = 1:numel(S)
          obj = evalin('caller', S(i).name);
          [flag, newobj] = fix_assumptions(obj, newx, xstr);
          if flag, assignin('caller', S(i).name, newobj); end
        end
        % --------------------------
        s = newx;
        return

      elseif (strcmp(asm, 'real') || strcmp(asm, 'positive') || ...
              strcmp(asm, 'integer') || strcmp(asm, 'even') || ...
              strcmp(asm, 'odd') || strcmp(asm, 'rational'))
        cmd = sprintf('z = sympy.Symbol("%s", %s=True)', x, asm);
      else
        error('that assumption not supported')
      end
    end % useSymbolNotS

  else
    x
    class(x)
    nargin
    error('conversion to symbolic with those arguments not (yet) supported');
  end

  s = python_cmd ([ cmd '\nreturn (z,)' ]);

end


%!test
%! assert (isa (sym (pi), 'sym'))
%! assert (isa (sym ('beta'), 'sym'))

%!test
%! %% assumptions and clearing them
%! x = sym('x', 'real');
%! f = {x {2*x}};
%! A = assumptions();
%! assert ( ~isempty(A))
%! x = sym('x', 'clear');
%! A = assumptions();
%! assert ( isempty(A))

%!test
%! %% matlab compat, syms x clear should add x to workspace
%! x = sym('x', 'real');
%! f = 2*x;
%! clear x
%! assert (~exist('x', 'var'))
%! x = sym('x', 'clear');
%! assert (exist('x', 'var'))
