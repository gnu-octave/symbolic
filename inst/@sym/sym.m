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
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{x} =} sym (@var{y})
%% @deftypefnx {Function File} {@var{x} =} sym (@var{y}, @var{assumestr})
%% @deftypefnx {Function File} {@var{x} =} sym (@var{y}, @var{assumestr1}, @var{assumestr2}, @dots{})
%% @deftypefnx {Function File} {@var{x} =} sym (@var{A}, [@var{n}, @var{m}])
%% Define symbols and numbers as symbolic expressions.
%%
%% @var{y} can be an integer, a string or one of several special
%% double values.  It can also be a double matrix or a cell
%% array.
%%
%% Examples:
%% @example
%% @group
%% >> x = sym ('x')
%%    @result{} x = (sym) x
%% >> y = sym ('2')
%%    @result{} y = (sym) 2
%% >> y = sym (3)
%%    @result{} y = (sym) 3
%% >> y = sym (inf)
%%    @result{} y = (sym) ∞
%% >> y = sym (pi)
%%    @result{} y = (sym) π
%% @end group
%% @end example
%%
%% A sym of a sym is a sym (idempotence):
%% @example
%% @group
%% >> sym (sym (pi))
%%    @result{} (sym) π
%% @end group
%% @end example
%%
%% A matrix can be input:
%% @example
%% @group
%% >> sym ([1 2; 3 4])
%%    @result{} (sym 2×2 matrix)
%%        ⎡1  2⎤
%%        ⎢    ⎥
%%        ⎣3  4⎦
%% @end group
%% @end example
%%
%% Boolean input, giving symbolic True/False:
%% @example
%% @group
%% >> sym (true)
%%    @result{} (sym) True
%% >> sym (false)
%%    @result{} (sym) False
%% @end group
%% @end example
%%
%% Some special double values are recognized but its all a
%% bit heuristic/magical:
%% @example
%% @group
%% >> y = sym(pi/100)
%%    @result{} warning: Using rat() heuristics for double-precision input (is this what you wanted?)
%%      y = (sym)
%%         π
%%        ───
%%        100
%% @end group
%% @end example
%% While this works fine for “small” fractions, its probably safer to do:
%% @example
%% @group
%% >> y = sym(pi)/100
%%    @result{} y = (sym)
%%         π
%%        ───
%%        100
%% @end group
%% @end example
%%
%%
%% A second (and further) arguments can provide assumptions
%% or restrictions on the type of the symbol:
%% @example
%% @group
%% >> x = sym ('x', 'positive')
%%    @result{} x = (sym) x
%% >> x = sym ('x', 'positive', 'integer')
%%    @result{} x = (sym) x
%% @end group
%% @end example
%% @xref{assumptions}, for the list of supported assumptions.
%%
%% Caution: it is possible to create multiple variants of the
%% same symbol with different assumptions.
%% @example
%% @group
%% >> x1 = sym('x')
%%    @result{} x1 = (sym) x
%% >> x2 = sym('x', 'positive')
%%    @result{} x2 = (sym) x
%% >> x1 == x2
%%    @result{} (sym) x = x
%% >> isAlways(x1 == x2)
%%    @result{} 0
%% >> logical(x1 == x2)
%    @result{} 0
%% @end group
%% @end example
%%
%% The second argument can also specify the size of a matrix:
%% @example
%% @group
%% >> A = sym('a', [2 3])
%%    @result{} A = (sym 2×3 matrix)
%%        ⎡a₁₁  a₁₂  a₁₃⎤
%%        ⎢             ⎥
%%        ⎣a₂₁  a₂₂  a₂₃⎦
%% @end group
%% @end example
%% or even with symbolic size:
%% @example
%% @group
%% >> syms m n positive integer
%% >> B = sym('B', [m n])
%%    @result{} B = (sym) B  (m×n matrix expression)
%% @end group
%% @end example
%%
%% The underlying SymPy “srepr” can also be passed directly to
%% @code{sym}: @pxref{char} for details.
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
  % Tempting to make a 'private constructor' but we need to access
  % this from the python ipc stuff: outside the class.  We identify
  % this non-user-facing usage by empty x and 6 inputs total.  Note
  % that "sym([])" is valid but "sym([], ...)" is otherwise not.
  if (isempty(x) && (nargin == 6))
    s.pickle = varargin{1};
    s.size = varargin{2};
    s.flat = varargin{3};
    s.ascii = varargin{4};
    s.unicode = varargin{5};
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
    s = sym(num2str(x, '%ld'));
    return

  elseif (isa (x, 'double')  &&  nargin==1)
    [s, flag] = magic_double_str(x);
    if (~flag)
      % Allow 1/3 and other "small" fractions.
      % Personally, I like a warning here so I can catch bugs.
      % Matlab SMT does this (w/o warning).
      % FIXME: could have sympy do this?  Or just make symbolic floats?
      warning('OctSymPy:sym:rationalapprox', ...
              'Using rat() heuristics for double-precision input (is this what you wanted?)');
      [N1, D1] = rat(x);
      [N2, D2] = rat(x/pi);
      if (10*abs(D2) < abs(D1))
        % use frac*pi if demoninator significantly shorter
        s = sprintf('Rational(%s, %s)*pi', num2str(N2), num2str(D2));
      else
        s = sprintf('Rational(%s, %s)', num2str(N1), num2str(D1));
      end
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

  elseif (isa (x, 'sym')  &&  (nargin >= 2))
    % support sym(x, assumption) for existing sym x
    s = sym(x.flat, varargin{:});
    return


  elseif (isa (x, 'char'))
    asm = [];
    if (nargin == 2 && isequal(size(varargin{1}), [1 2]))
      s = make_sym_matrix(x, varargin{1});
      return
    elseif (nargin >= 2)
      % assume the remaining inputs are assumptions
      asm = varargin;
    end

    doDecimalCheck = true;

    % preprocess
    if (strcmpi(x, 'inf')) || (strcmpi(x, '+inf'))
      x = 'oo';
    elseif (strcmpi(x, '-inf'))
      x = '-oo';
    elseif (strcmpi(x, 'i'))
      x = 'I';
    elseif (strcmpi(x, '-i'))
      x = '-I';
    elseif (strcmpi(x, 'nan'))
      x = 'nan';
    elseif (strcmp(x, 'lambda'))
      x = 'lamda';
    elseif (strcmp(x, 'Lambda'))
      x = 'Lamda';
    end

    % Decide whether to pass to S() or Symbol()
    if (any(strcmp(x, {'pi', 'I', 'oo', 'zoo', 'nan'})))
      useSymbolNotS = false;
    elseif (regexp(x, '^-?\d*\.?\d*(e-?\d+)?$'))
      % Numbers: integers and floats
      useSymbolNotS = false;
    elseif (regexp(x, '^\w+$'))
      % Words.  Note must follow numbers case.
      % Use Symbol instead of S, e.g., for Issue #23:
      % strcmp(x, {'beta' 'gamma' 'zeta' 'Chi' 'E' 'E1' 'Ei' 'S' 'N' 'Q'})
      % But we also expect sym('Eq') to work, so match all single words
      useSymbolNotS = true;
    elseif (~isempty (strfind (x, '(') ))
      % SymPy "srepr" or other raw python code
      useSymbolNotS = false;
      doDecimalCheck = false;
    else
      % Other non-symbols such as sym('1/3')
      useSymbolNotS = false;
    end

    if (~useSymbolNotS)
      % Use S(), as we're not forcing Symbol()
      assert (isempty (asm))   % sym('pi', 'integer')
      if (doDecimalCheck && ~isempty(strfind(x, '.')))
        warning('possibly unintended decimal point in constructor string');
      end
      % x is raw sympy, could have various quotes in it
      cmd = sprintf('z = sympy.S("%s")', strrep(x, '"', '\"'));

    else % useSymbolNotS
      if (isempty(asm))
        cmd = sprintf('z = sympy.Symbol("%s")', x);

      elseif (isscalar(asm) && isscalar(asm{1}) && isstruct(asm{1}))
        % we have an assumptions dict
        cmd = sprintf('return sympy.Symbol("%s", **_ins[0]),', x);
        s = python_cmd (cmd, asm{1});
        return

      elseif (iscell(asm))
        valid_asm = assumptions('possible');
        for n=1:length(asm)
          assert(ischar(asm{n}), 'sym: assumption must be a string')
          assert(ismember(asm{n}, valid_asm), ...
                 'sym: that assumption is not supported')
        end
        cmd = ['z = sympy.Symbol("' x '"' ...
               sprintf(', %s=True', asm{:}) ')'];
      else
        error('sym: invalid extra input, perhaps invalid assumptions?');
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

%!warning <heuristic> x = sym(1/2);

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
%! % moar empty
%! a = sym('a', [0 3]);
%! assert (isa (a, 'sym'))
%! assert (isequal (size (a), [0 3]))
%! a = sym('a', [2 0]);
%! assert (isa (a, 'sym'))
%! assert (isequal (size (a), [2 0]))

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

%!xtest
%! % bigger int64 integer types: TODO: passes on Octave 4?
%! q = int64(123456789012345);
%! w = 10000*q + 123;
%! a = sym('1234567890123450123');
%! b = sym(w);
%! assert (isequal (a, b))

%!test
%! % sym(double) heuristic
%! s = warning ('off', 'OctSymPy:sym:rationalapprox');
%! x = sym(2*pi/3);
%! assert (isequal (x/sym(pi), sym(2)/3))
%! x = sym(22*pi);
%! assert (isequal (x/sym(pi), sym(22)))
%! x = sym(pi/123);
%! assert (isequal (x/sym(pi), sym(1)/123))
%! warning (s)

%!test
%! % symbols with special sympy names
%! syms Ei Eq
%! assert (~isempty(regexp(char(Eq), '^Symbol')))
%! assert (~isempty(regexp(char(Ei), '^Symbol')))

%!test
%! % E can be a sym not just exp(sym(1))
%! syms E
%! assert (~logical (E == exp(sym(1))))

%!error <assumption is not supported>
%! x = sym('x', 'positive2');

%!error <assumption is not supported>
%! x = sym('x', 'integer', 'positive2');

%!error <assumption is not supported>
%! x = sym('x', 'integer2', 'positive');

%!error <failed>
%! x = sym('-pi', 'positive')

%!error <failed>
%! x = sym('pi', 'integer')

%!xtest
%! % multiple assumptions
%! % FIXME: xtest for sympy <= 0.7.6.x where a is the full dict
%! n = sym('n', 'negative', 'even');
%! a = assumptions(n);
%! assert(strcmp(a, 'n: negative, even') || strcmp(a, 'n: even, negative'))
%! % FIXME: slightly obtuse testing b/c 0.7.6 but still fails on 0.7.5
%! assert (isequal (n > 0, sym(false)))
%! assert (isequal (n == -1, sym(false)))
