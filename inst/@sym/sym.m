%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefnx {Function File} {@var{x} =} sym (@var{y}, @var{assumestr})
%% @deftypefnx {Function File} {@var{x} =} sym (@var{A}, [@var{n}, @var{m}])
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
%% A second argument can provide an assumption @xref{assumptions},
%% or restriction on the type of the symbol.
%% @example
%% x = sym ('x', 'positive')
%% @end example
%% The following options are supported:
%% 'real', 'positive', 'negative', 'integer', 'even', 'odd',
%% 'rational', 'finite'.
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
%% The second argument can also specify the size of a matrix
%% @example
%% A = sym('A', [2, 3])
%% @end example
%% or even with symbolic size
%% @example
%% syms n positive
%% A = sym('A', [n, n])
%% @end example
%%
%% @seealso{syms, assumptions, assume, assumeAlso}
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
    s.flat = varargin{2};
    s.ascii = varargin{3};
    s.unicode = varargin{4};
    s.extra = [];
    s = class(s, 'sym');
    return
  end

  %% User interface for defining sym
  % sym(1), sym('x'), etc.

  %if (strcmp (class (x), 'symfun')  &&  nargin==1)
  %  % FIXME: pass a symfun to sym() ctor; convert to pure sym
  %  % (SMT does not do this in 2014a).  bad idea?
  %  s = x.sym;
  %  return

  if (isa (x, 'sym')  &&  nargin==1)
    % matches sym and subclasses
    s = x;
    return

  elseif (iscell (x)  &&  nargin==1)
    s = cell_array_to_sym (x);
    return

  elseif (isnumeric(x)  &&  ~isscalar (x)  &&  nargin==1)
    s = numeric_array_to_sym (x);
    return

  elseif (islogical (x)  &&  ~isscalar (x)  &&  nargin==1)
    s = numeric_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isreal (x)  &&  nargin==1)
    s = sym(real(x)) + sym('I')*sym(imag(x));
    return

  elseif (isinteger(x)  &&  nargin==1)
    s = sym(num2str(x));
    return

  elseif (isa (x, 'double')  &&  nargin==1)
    [s, flag] = magic_double_str(x);
    if (~flag)
      % Allow 1/3 and other "small" fractions.
      % Personally, I like a warning here so I can catch bugs.
      % Matlab SMT does this (w/o warning).
      % FIXME: could have sympy do this?  Or just make symbolic floats?
      warning('OctSymPy:sym:rationalapprox', ...
              'Using rat() for rational approx (are you sure you want to pass a noninteger?)');
      [N, D] = rat(x, 1e-15);
      s = sprintf('Rational(%s, %s)', num2str(N), num2str(D));
    end
    s = sym(s);
    return

  elseif (islogical (x)  &&  isscalar(x)  &&  nargin==1)
    if (x)
      cmd = 'z = sp.S.true';
    else
      cmd = 'z = sp.S.false';
    end

  elseif (nargin == 2 && ischar(varargin{1}) && strcmp(varargin{1},'clear'))
    % special case for 'clear', because of side-effects
    if (isa(x, 'sym'))
      x = x.flat;    % we just want the string
    end
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
    s = sym(x.flat, varargin{1});
    return


  elseif (isa (x, 'char'))
    useSymbolNotS = false;
    cmd = [];

    asm = [];
    if (nargin == 2 && isequal(size(varargin{1}), [1 2]))
      s = make_sym_matrix(x, varargin{1});
      return
    elseif (nargin == 2)
      % we have assumptions
      asm = varargin{1};
      useSymbolNotS = true;
    end

    doDecimalCheck = true;

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
    elseif (~isempty (strfind (x, '(') ))
      %disp('debug: has a "(", not a symfun, assuming srepr!')
      useSymbolNotS = false;
      doDecimalCheck = false;
    else
      %disp(['debug: just a regular symbol: ' x])
    end

    if (~useSymbolNotS)
      % if we're not forcing Symbol() then we use S(), unless
      % cmd already set.
      if (isempty(cmd))
        if (doDecimalCheck && ~isempty(strfind(x, '.')))
          warning('possibly unintended decimal point in constructor string');
        end
        % x is raw sympy, could have various quotes in it
        cmd = sprintf('z = sympy.S("%s")', strrep(x, '"', '\"'));
      end
    else % useSymbolNotS
      assert(isempty(cmd), 'inconsistent input')
      if isempty(asm)
        cmd = sprintf('z = sympy.Symbol("%s")', x);
      elseif isstruct(asm) && isscalar(asm)
        % we have an assumptions dict
        cmd = { sprintf('s = sympy.Symbol("%s", **_ins[0])', x) ...
                        'return s,' };
        s = python_cmd (cmd, asm);
        return

      % FIXME: split out some helper with list of assumptions we
      % consider valid?  Also syms.m and assumptions.m tests.
      elseif (strcmp(asm, 'real') || strcmp(asm, 'positive') || ...
              strcmp(asm, 'negative') || strcmp(asm, 'integer') || ...
              strcmp(asm, 'even') || strcmp(asm, 'odd') || ...
              strcmp(asm, 'rational') || strcmp(asm, 'finite'))
        cmd = sprintf('z = sympy.Symbol("%s", %s=True)', x, asm);
      else
        error('sym: that assumption not supported')
      end
    end % useSymbolNotS

  else
    x
    class(x)
    nargin
    error('conversion to symbolic with those arguments not (yet) supported');
  end

  s = python_cmd ({cmd 'return z,'});

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
%! assert (isa (x, 'sym'))
%! assert (isequal (sin(x), sym(0)))
%! assert (abs(double(x) - pi) < 2*eps )
%! x = sym(pi);
%! assert ( isa (x, 'sym'))
%! assert ( isequal (sin(x), sym(0)))
%! assert ( abs(double(x) - pi) < 2*eps )

%!test
%! % rationals
%! x = sym(1) / 3;
%! assert (isa (x, 'sym'))
%! assert (isequal (3*x - 1, sym(0)))
%! x = 1 / sym(3);
%! assert (isa (x, 'sym'))
%! assert (isequal (3*x - 1, sym(0)))
%! x = sym('1/3');
%! assert (isa (x, 'sym'))
%! assert (isequal (3*x - 1, sym(0)))

%!test
%! % passing small rationals
%! x = sym('1/2');
%! assert( double(x) == 1/2 )
%! assert( isequal( 2*x, sym(1)))

%!warning <rational approx> x = sym(1/2);

%!test
%! % passing small rationals w/o quotes: despite the warning,
%! % it should work
%! s = warning ('off', 'OctSymPy:sym:rationalapprox');
%! x = sym(1/2);
%! warning (s)
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
%! clear  % for matlab test script
%! x = sym('x', 'real');
%! f = {x {2*x}};
%! asm = assumptions();
%! assert ( ~isempty(asm))
%! x = sym('x', 'clear');
%! asm = assumptions();
%! assert ( isempty(asm))

%!test
%! %% matlab compat, syms x clear should add x to workspace
%! x = sym('x', 'real');
%! f = 2*x;
%! clear x
%! assert (~logical(exist('x', 'var')))
%! x = sym('x', 'clear');
%! assert (logical(exist('x', 'var')))

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

%!test
%! % bool
%! t = sym(false);
%! t = sym(true);
%! assert (logical (t))

%!test
%! % bool vec/mat
%! a = sym(1);
%! t = sym([true false]);
%! assert (isequal (t, [a==1  a==0]))
%! t = sym([true false; false true]);
%! assert (isequal (t, [a==1  a==0;  a==0  a==1]))

%!test
%! % symbolic matrix
%! A = sym('A', [2 3]);
%! assert (isa (A, 'sym'))
%! assert (isequal (size (A), [2 3]))
%! A(1, 1) = 7;
%! assert (isa (A, 'sym'))
%! A = A + 1;
%! assert (isa (A, 'sym'))

%!test
%! % symbolic matrix, subs in for size
%! syms n m integer
%! A = sym('A', [n m]);
%! B = subs(A, [n m], [5 6]);
%! assert (isa (B, 'sym'))
%! assert (isequal (size (B), [5 6]))

%!test
%! % 50 shapes of empty
%! a = sym(ones(0, 3));
%! assert (isa (a, 'sym'))
%! assert (isequal (size (a), [0 3]))
%! a = sym(ones(2, 0));
%! assert (isequal (size (a), [2 0]))
%! a = sym([]);
%! assert (isequal (size (a), [0 0]))

%!test
%! % embedded sympy commands, various quotes, issue #143
%! a = sym('a');
%! a1 = sym('Symbol("a")');
%! a2 = sym('Symbol(''a'')');
%! assert (isequal (a, a1))
%! assert (isequal (a, a2))
%! % Octave only, and eval to hide from Matlab parser
%! if exist('octave_config_info', 'builtin')
%!   eval( 'a3 = sym("Symbol(''a'')");' );
%!   eval( 'a4 = sym("Symbol(\"a\")");' );
%!   assert (isequal (a, a3))
%!   assert (isequal (a, a4))
%! end

%!test
%! % doubles bigger than int32 INTMAX should not fail
%! d = 4294967295;
%! a = sym(d);
%! assert (isequal (double(a), d))
%! d = d + 123456;
%! a = sym(d);
%! assert (isequal (double(a), d))

%!test
%! % int32 integer types
%! a = sym(100);
%! b = sym(int32(100));
%! assert (isequal (a, b))

%!test
%! % int32 MAXINT integers
%! a = sym('2147483647');
%! b = sym(int32(2147483647));
%! assert (isequal (a, b))
%! a = sym('-2147483647');
%! b = sym(int32(-2147483647));
%! assert (isequal (a, b))
%! a = sym('4294967295');
%! b = sym(uint32(4294967295));
%! assert (isequal (a, b))

%!test
%! % int64 integer types
%! a = sym('123456789012345');
%! b = sym(int64(123456789012345));
%! c = sym(uint64(123456789012345));
%! assert (isequal (a, b))
%! assert (isequal (a, c))

%!test
%! % integer arrays
%! a = int64([1 2 100]);
%! s = sym(a);
%! assert (isequal (double(a), [1 2 100]))
