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
%% @seealso{syms,assumptions,assume,assumeAlso}
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

  elseif (nargin == 2 && ischar(varargin{1}) && strcmp(varargin{1},'clear'))
    % special case for 'clear', because of side-effects
    x = strtrim(disp(x));  % we just want the string
    s = sym(x);
    % ---------------------------------------------
    % Muck around in the caller's namespace, replacing syms
    % that match 'xstr' (a string) with the 'newx' sym.
    xstr = x;
    newx = s;
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
    return

  elseif (isa (x, 'sym')  &&  nargin==2)
    % support sym(x, assumption) for existing sym x
    s = sym(strtrim(disp(x)), varargin{1});
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
%! % integers
%! x = sym('2');
%! y = sym(2);
%! assert (isa(x, 'sym'))
%! assert (isa(y, 'sym'))
%! assert (isequal(x, y))

%!test
%! % infinity
%! for x = {'inf', '-inf', inf, -inf, 'Inf'}
%!   y = sym(x{1});
%!   assert (isa(y, 'sym'))
%!   assert (isinf(double(y)))
%!   assert (isinf(y))
%! end

%!test
%! % pi
%! x = sym('pi');
%! assert (isa(x, 'sym'))
%! assert (sin(x) == sym(0))
%! assert ( abs(double(x) - pi) < 2*eps )
%! x = sym(pi);
%! assert (isa(x, 'sym'))
%! assert (sin(x) == sym(0))
%! assert ( abs(double(x) - pi) < 2*eps )

%!test
%! % rationals
%! x = sym(1) / 3;
%! assert (isa(x, 'sym'))
%! assert (3*x - 1 == 0)
%! x = 1 / sym(3);
%! assert (isa(x, 'sym'))
%! assert (3*x - 1 == 0)
%! x = sym('1/3');
%! assert (isa(x, 'sym'))
%! assert (3*x - 1 == 0)

%!test
%! % passing small rationals
%! x = sym('1/2');
%! assert( double(x) == 1/2 )
%! assert( isequal( 2*x, sym(1)))

%!test
%! % passing small rationals w/o quotes
%! fprintf('\n*** One warning expected ***\n')
%! x = sym(1/2);
%! assert( double(x) == 1/2 )
%! assert( isequal( 2*x, sym(1)))

%!test
%! assert (isa (sym (pi), 'sym'))
%! assert (isa (sym ('beta'), 'sym'))

%!test
%! % sym from array
%! D = [0 1; 2 3];
%! A = [sym(0) 1; sym(2) 3];
%! assert (isa (sym(D), 'sym'))
%! assert (isequal ( size(sym(D)) , size(D) ))
%! assert (isequal ( sym(D) , A ))

%!test
%! % more sym from array
%! syms x
%! A = [x x];
%! assert (isequal ( sym(A), A ))
%! A = [1 x];
%! assert (isequal ( sym(A), A ))

%!test
%! % Cell array lists to syms
%! % (these tests are pretty weak, doens't recursively compare two
%! % cells, but just running this is a good test.
%! x = sym('x');
%!
%! a = {1 2};
%! s = sym(a);
%! assert (isequal( size(a), size(s) ))
%!
%! a = {1 2 {3 4}};
%! s = sym(a);
%! assert (isequal( size(a), size(s) ))
%!
%! a = {1 2; 3 4};
%! s = sym(a);
%! assert (isequal( size(a), size(s) ))
%!
%! a = {1 2; 3 {4}};
%! s = sym(a);
%! assert (isequal( size(a), size(s) ))
%!
%! a = {1 [1 2] x [sym(pi) x]};
%! s = sym(a);
%! assert (isequal( size(a), size(s) ))
%! assert (isequal( size(a{2}), size(s{2}) ))
%! assert (isequal( size(a{4}), size(s{4}) ))
%!
%! a = {{{[1 2; 3 4]}}};
%! s = sym(a);
%! assert (isequal( size(a), size(s) ))
%! assert (isequal( size(a{1}), size(s{1}) ))
%! assert (isequal( size(a{1}{1}), size(s{1}{1}) ))
%! assert (isequal( size(a{1}{1}{1}), size(s{1}{1}{1}) ))


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

%!test
%! %% assumptions should work if x is already a sym
%! x = sym('x');
%! x = sym(x, 'real');
%! assert (~isempty(assumptions(x)))

%!test
%! %% likewise for clear
%! x = sym('x', 'real');
%! f = 2*x;
%! x = sym(x, 'clear');
%! assert (isempty(assumptions(x)))
%! assert (isempty(assumptions(f)))
