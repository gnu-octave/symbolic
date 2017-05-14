%% Copyright (C) 2014-2017 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
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
%% @deftypeop  Constructor @@sym {@var{x} =} sym (@var{y})
%% @deftypeopx Constructor @@sym {@var{x} =} sym (@var{y}, @var{assumestr})
%% @deftypeopx Constructor @@sym {@var{x} =} sym (@var{y}, @var{assumestr1}, @var{assumestr2}, @dots{})
%% @deftypeopx Constructor @@sym {@var{x} =} sym (@var{A}, [@var{n}, @var{m}])
%% Define symbols and numbers as symbolic expressions.
%%
%% @var{y} can be an integer, a string or one of several special
%% double values.  It can also be a double matrix or a cell
%% array.
%%
%% Examples:
%% @example
%% @group
%% x = sym ('x')
%%   @result{} x = (sym) x
%% y = sym ('2')
%%   @result{} y = (sym) 2
%% y = sym (3)
%%   @result{} y = (sym) 3
%% y = sym (inf)
%%   @result{} y = (sym) ∞
%% y = sym (pi)
%%   @result{} y = (sym) π
%% y = sym (1i)
%%   @result{} y = (sym) ⅈ
%% @end group
%% @end example
%%
%% A sym of a sym is a sym (idempotence):
%% @example
%% @group
%% sym (sym (pi))
%%   @result{} (sym) π
%% @end group
%% @end example
%%
%% A matrix of integers can be input:
%% @example
%% @group
%% sym ([1 2; 3 4])
%%   @result{} (sym 2×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%% @end group
%% @end example
%%
%% However, if the entries are not simply integers, its better to call
%% @code{sym} inside the matrix:
%% @example
%% @group
%% [sym(pi) sym(3)/2; sym(1) 0]
%%   @result{} (sym 2×2 matrix)
%%       ⎡π  3/2⎤
%%       ⎢      ⎥
%%       ⎣1   0 ⎦
%% @end group
%% @end example
%% (Careful: at least one entry per row must be @code{sym} to workaround
%% a GNU Octave bug @url{https://savannah.gnu.org/bugs/index.php?42152}.)
%% @c @example
%% @c [sym(pi) 2; 1 0]-
%% @c   @print{} ??? octave_base_value::map_value(): wrong type argument 'scalar'
%% @c @end example
%%
%% Passing double values to sym is not recommended and will give a warning:
%% @example
%% @group
%% sym(0.1)
%%   @print{} warning: passing floating-point values to sym is dangerous, see "help sym"
%%   @result{} ans = (sym) 1/10
%% @end group
%% @end example
%%
%% In this particular case, the warning is easy to avoid:
%% @example
%% @group
%% sym(1)/10
%%   @result{} (sym) 1/10
%% @end group
%% @end example
%%
%% The ``danger'' here is that typing @code{0.1} gives a double-precision
%% floating-point value which differs slightly from the fraction
%% @code{sym(1)/10} (and this is true for most decimal expressions).
%% It is generally impossible to determine which exact symbolic value the
%% user intended.
%% The warning indicates that some heuristics have been applied,
%% namely a preferance for ``small'' fractions (and small fractions
%% of π).
%% Further examples include:
%% @example
%% @group
%% y = sym(pi/100)
%%   @print{} warning: passing floating-point values to sym is dangerous, see "help sym"
%%   @result{} y = (sym)
%%        π
%%       ───
%%       100
%% @end group
%%
%% @group
%% y = sym(pi)/100
%%   @result{} y = (sym)
%%        π
%%       ───
%%       100
%% @end group
%% @end example
%% (@code{sym(pi)} is a special case; it does not raise the warning).
%%
%%
%% There is an additional reason for the float-point warning,
%% relevant if you are doing something like @code{sym(1.23456789012345678)}.
%% In many cases, floating-point numbers should be thought of as
%% approximations (with about 15 decimal digits of relative accuracy).
%% This means that mixing floating-point values and symbolic computations
%% with the goal of obtaining exact results is often a fool's errand.
%% Compounding this, symbolic computations may not always use numerically
%% stable algorithms (as their inputs are assumed exact) whereas a
%% floating-point input is effectively perturbed in the 15th digit.
%%
%% If what you really want is higher-precision floating-point
%% computations, @pxref{vpa}.
%%
%%
%% For symbols, a second (and further) arguments can provide assumptions
%% or restrictions on the type of the symbol:
%% @example
%% @group
%% x = sym ('x', 'positive')
%%   @result{} x = (sym) x
%% x = sym ('x', 'positive', 'integer')
%%   @result{} x = (sym) x
%% @end group
%% @end example
%% @xref{assumptions}, for the list of supported assumptions.
%%
%% Caution: it is possible to create multiple variants of the
%% same symbol with different assumptions.
%% @example
%% @group
%% x1 = sym('x')
%%   @result{} x1 = (sym) x
%% x2 = sym('x', 'positive')
%%   @result{} x2 = (sym) x
%% x1 == x2
%%   @result{} (sym) x = x
%% isAlways(x1 == x2)
%%   @result{} 0
%% logical(x1 == x2)
%%   @result{} 0
%% @end group
%% @end example
%%
%% The second argument can also specify the size of a matrix:
%% @example
%% @group
%% A = sym('a', [2 3])
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡a₁₁  a₁₂  a₁₃⎤
%%       ⎢             ⎥
%%       ⎣a₂₁  a₂₂  a₂₃⎦
%% @end group
%% @end example
%% or even with symbolic size:
%% @example
%% @group
%% syms m n positive integer
%% B = sym('B', [m n])
%%   @result{} B = (sym) B  (m×n matrix expression)
%% @end group
%% @end example
%%
%% It is also possible to save sym objects to file and then load them when
%% needed in the usual way with the @code{save} and @code{load} commands.
%%
%% The underlying SymPy string representation (``srepr'') can usually be passed
%% directly to @code{sym}: @pxref{@@sym/char} for discussion of the details.
%%
%% @seealso{syms, assumptions, @@sym/assume, @@sym/assumeAlso}
%% @end deftypeop


function s = sym(x, varargin)

  if (nargin == 0)
    x = 0;
  end

  %% The actual class constructor
  % Tempting to make a 'private constructor' but we need to access
  % this from the python ipc stuff: outside the class.  We identify
  % this non-user-facing usage by empty x and 6 inputs total.  Note
  % that "sym([])" is valid but "sym([], ...)" is otherwise not.
  if (isempty (x) && nargin == 6)
    s.pickle = varargin{1};
    s.size = varargin{2};
    s.flat = varargin{3};
    s.ascii = varargin{4};
    s.unicode = varargin{5};
    s.extra = [];
    s = class (s, 'sym');
    return
  end

  %% User interface for defining sym
  % sym(1), sym('x'), etc.

  %if (strcmp (class (x), 'symfun')  &&  nargin==1)
  %  % FIXME: pass a symfun to sym() ctor; convert to pure sym
  %  % (SMT does not do this in 2014a).  bad idea?
  %  s = x.sym;
  %  return

  if (isa (x, 'sym'))
    if (nargin == 1)
      s = x;
      return
    else
      x = x.flat;
    end
  end

  if (iscell (x))  % Handle Cells
    warning ('OctSymPy:deprecated', ...
            ['creating a cell array of sym using "sym(cell)" is deprecated;\n' ...
             '         future versions will instead create a sym array.']);
    s = cell_array_to_sym (x, varargin{:});
    return
  end

  asm = {};
  check = true;
  isnumber = isnumeric (x) || islogical (x);
  ratwarn = true;
  ratflag = 'r';

  if (nargin >= 2)
    if (ismatrix (varargin{1}) && ~ischar (varargin{1}) && ~isstruct (varargin{1}) && ~iscell (varargin{1}))
      %% Handle MatrixSymbols
      assert (nargin < 3, 'MatrixSymbol do not support assumptions')
      s = make_sym_matrix (x, varargin{1});
      return
    elseif (nargin == 2 && ischar (varargin{1}) && strcmp (varargin{1}, 'clear'))
      sclear = true;
      varargin(1) = [];
      warning ('OctSymPy:deprecated', ...
              ['"sym(x, ''clear'')" is deprecated and will be removed in a future version;\n' ...
               '         use "assume(x, ''clear'')" instead.'])
    else
      sclear = false;
      assert (~isnumber, 'Only symbols can have assumptions.')
      check_assumptions (varargin);  % Check if assumptions exist - Sympy don't check this
      asm = varargin;
    end
  end

  if (~isscalar (x) && isnumber)  % Handle octave numeric matrix
    s = numeric_array_to_sym (x);
    return

  elseif (isa (x, 'double'))  % Handle doubles
    check = false;

    switch ratflag
      case 'r'
        iscmplx = ~isreal (x);
        if (iscmplx)
          xx = {real(x); imag(x)};
        else
          xx = {x};
        end
        ss = cell(2, 1);

        for n = 1:numel (xx)
          tmpx = xx{n};
          [ss{n}, flag] = const_to_python_str (tmpx);
          if (~flag)
            % Allow 1/3 and other "small" fractions.
            % Personally, I like a warning here so I can catch bugs.
            % Matlab SMT does this (w/o warning).
            if (ratwarn)
              warning('OctSymPy:sym:rationalapprox', ...
                      'passing floating-point values to sym is dangerous, see "help sym"');
            end
            [N1, D1] = rat (tmpx);
            [N2, D2] = rat (tmpx / pi);
            if (10*abs (D2) < abs (D1))
              % use frac*pi if demoninator significantly shorter
              ss{n} = sprintf ('Rational(%s, %s)*pi', num2str (N2), num2str (D2));
            else
              ss{n} = sprintf ('Rational(%s, %s)', num2str (N1), num2str (D1));
            end
          else
            ss{n} = sprintf ('S(%s)', ss{n});
          end
        end

        if (iscmplx)
          x = sprintf ('%s + I*(%s)', ss{1}, ss{2});
        else
          x = ss{1};
        end

      otherwise
        error ('sym: this case should not be possible')
    end

  elseif (islogical (x)) % Handle logical values
    check = false;
    if (x)
      x = 'S.true';
    else
      x = 'S.false';
    end

  elseif (isinteger (x)) % Handle integer vealues
    check = false;
    x = num2str (x, '%ld');
  end

  if (isa (x, 'char'))
    % We now have a char; need to decide whether to use S() or Symbol() on it.

    if (check)
      % TODO: Warning if you try make a sym with the same name of a system function.
      %symsnotfunc (x);

      % TODO: tests pass without this?  Is there a example where this is needed?
      %% sym('---1') -> '-' '1' Split first symbols to can search operators correctly.
      %r = 1;
      %xc = '';  % Used to check operators skipping first symbols
      %for i = 1:length (x)
      %  if (strcmp (x (i), '-'))
      %    r = r*-1;
      %  elseif (~strcmp (x (i), '+'))
      %    if (r == -1)
      %      xc = x (i:end);
      %      x = ['-' x(i:end)];
      %    else
      %      x = xc = x (i:end);
      %    end
      %    break
      %  end
      %end

      [x, flag] = const_to_python_str (x);
      if (flag)
        check = false;
      end
      x = strrep (x, '"', '\"');   % Avoid collision with S("x") and Symbol("x")

      isnum = ~isempty (regexp (x, '^[-+]*?\d*\.?\d*(e-?\d+)?$'));  % Is Number
    end

    %% Use Symbol() for words, not numbers, not "f(x)".
    if (check && (~ isnum) && (~ isempty (regexp (x, '^\w+$'))))

      cmd = { 'd = dict()'
              '_ins = [_ins] if isinstance(_ins, dict) else _ins'
              'for i in range(len(_ins)):'
              '    if isinstance(_ins[i], dict):'
              '        d.update(_ins[i])'
              '    #elif isinstance(_ins[i], list):'  % TODO: allow a list?
              '    #    for j in range(len(_ins[i])):'
              '    #        d.update({_ins[i][j]:True})'
              '    elif isinstance(_ins[i], (str, bytes)):'
              '        d.update({_ins[i]:True})'
              '    else:'
              '        raise ValueError("something unexpected in assumptions")'
              'return Symbol("{s}", **d)' };
      s = python_cmd (strrep (cmd, '{s}', x), asm{:});

      if (nargin == 2 && sclear)
        % ---------------------------------------------
        % Muck around in the caller's namespace, replacing syms
        % that match 'xstr' (a string) with the 'newx' sym.
        context = 'caller';
        S = evalin(context, 'whos');
        evalin(context, '[];');  % clear 'ans'
        for i = 1:numel(S)
          obj = evalin(context, S(i).name);
          [newobj, flag] = symreplace(obj, x, s);
          if flag, assignin(context, S(i).name, newobj); end
        end
        % ---------------------------------------------
      end

      return

    else % S() in other case

      assert (isempty (asm), 'Only symbols can have assumptions.')

      % TODO: figure version might warn on expression strings
      %if (check)
        % Check if the user try to execute operations from sym
        %if (~isempty (regexp (xc, '\!|\&|\^|\:|\*|\/|\\|\+|\-|\>|\<|\=|\~')))
        %  warning ('Please avoid execute operations from sym function.');
        %end
      %end

      % Usually want rational output here (i.e., if input was "1.2").
      % But if input has words and parentheses it might be raw Sympy code.
      if (isempty (regexp (x, '\w\(.*\)')))
        s = python_cmd (['return S("' x '", rational=True)']);
        return
      end

      cmd = {'x = "{s}"'
             'try:'
             '    return (0, 0, S(x))'
             'except Exception as e:'
             '    lis = set()'
             '    if "(" in x or ")" in x:'
             '        x2 = split("\(|\)| |,", x)'
             '        x2 = [p for p in x2 if p]'
             '        for i in x2:'
             '            try:'
             '                if eval("callable(" + i + ")"):'
             '                    lis.add(i)'
             '            except:'
             '                pass'
             '    if len(lis) > 0:'
             '        return (str(e), 1, "\", \"".join(str(e) for e in lis))'
             '    return (str(e), 2, 0)' };

      [err flag s] = python_cmd (strrep (cmd, '{s}', x));

      switch (flag)
        case 1  % Bad call to python function
          error (['Python: %s\n' ...
                  'Error occurred using "%s" Python function, perhaps use another variable name?'], ...
                 err, s);
        case 2  % Something else
          error (['Python: %s\n' ...
                  'Seems you cannot use "%s" for a variable name; perhaps this is a bug?'], ...
                 err, x);
      end
      return

    end
  end

  error ('Conversion to symbolic with those arguments not (yet) supported')

end


%!test
%! % integers
%! x = sym ('2');
%! y = sym (2);
%! assert (isa (x, 'sym'))
%! assert (isa (y, 'sym'))
%! assert (isequal (x, y))

%!test
%! % infinity
%! for x = {'inf', '-inf', inf, -inf, 'Inf'}
%!   y = sym (x{1});
%!   assert (isa (y, 'sym'))
%!   assert (isinf (double (y)))
%!   assert (isinf (y))
%! end

%!test
%! % pi
%! x = sym ('pi');
%! assert (isa (x, 'sym'))
%! assert (isequal (sin (x), sym (0)))
%! assert (abs (double (x) - pi) < 2*eps )
%! x = sym (pi);
%! assert (isa (x, 'sym'))
%! assert (isequal (sin (x), sym (0)))
%! assert (abs (double (x) - pi) < 2*eps )

%!test
%! % rationals
%! x = sym(1) / 3;
%! assert (isa (x, 'sym'))
%! assert (isequal (3*x - 1, sym (0)))
%! x = 1 / sym (3);
%! assert (isa (x, 'sym'))
%! assert (isequal (3*x - 1, sym (0)))
%! x = sym ('1/3');
%! assert (isa (x, 'sym'))
%! assert (isequal (3*x - 1, sym (0)))

%!test
%! % passing small rationals
%! x = sym ('1/2');
%! assert (double (x) == 1/2 )
%! assert (isequal (2*x, sym (1)))

%!warning <dangerous> x = sym (1/2);

%!test
%! % passing small rationals w/o quotes: despite the warning,
%! % it should work
%! s = warning ('off', 'OctSymPy:sym:rationalapprox');
%! x = sym (1/2);
%! warning (s)
%! assert (double (x) == 1/2 )
%! assert (isequal (2*x, sym (1)))

%!test
%! assert (isa (sym (pi), 'sym'))
%! assert (isa (sym ('beta'), 'sym'))

%!test
%! % sym from array
%! D = [0 1; 2 3];
%! A = [sym(0) 1; sym(2) 3];
%! assert (isa (sym (D), 'sym'))
%! assert (isequal (size (sym (D)), size (D)))
%! assert (isequal (sym (D), A))

%!test
%! % more sym from array
%! syms x
%! A = [x x];
%! assert (isequal (sym (A), A))
%! A = [1 x];
%! assert (isequal (sym (A), A))

%!test
%! %% assumptions and clearing them
%! clear variables  % for matlab test script
%! x = sym('x', 'real');
%! f = {x {2*x}};
%! asm = assumptions();
%! assert ( ~isempty(asm))
%! s = warning ('off', 'OctSymPy:deprecated');
%! x = sym('x', 'clear');
%! warning (s)
%! asm = assumptions();
%! assert ( isempty(asm))

%!test
%! %% matlab compat, syms x clear should add x to workspace
%! x = sym('x', 'real');
%! f = 2*x;
%! clear x
%! assert (~logical(exist('x', 'var')))
%! s = warning ('off', 'OctSymPy:deprecated');
%! x = sym('x', 'clear');
%! warning (s)
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
%! s = warning ('off', 'OctSymPy:deprecated');
%! x = sym(x, 'clear');
%! warning (s)
%! assert (isempty(assumptions(x)))
%! assert (isempty(assumptions(f)))

%!test
%! % bool
%! t = sym (false);
%! t = sym (true);
%! assert (logical (t))

%!test
%! % bool vec/mat
%! a = sym (1);
%! t = sym ([true false]);
%! assert (isequal (t, [a == 1  a == 0]))
%! t = sym ([true false; false true]);
%! assert (isequal (t, [a == 1  a == 0;  a == 0  a == 1]))

%!test
%! % symbolic matrix
%! A = sym ('A', [2 3]);
%! assert (isa (A, 'sym'))
%! assert (isequal (size (A), [2 3]))
%! A(1, 1) = 7;
%! assert (isa (A, 'sym'))
%! A = A + 1;
%! assert (isa (A, 'sym'))

%!test
%! % symbolic matrix, subs in for size
%! syms n m integer
%! A = sym ('A', [n m]);
%! B = subs (A, [n m], [5 6]);
%! assert (isa (B, 'sym'))
%! assert (isequal (size (B), [5 6]))

%!error <Cannot create symbolic matrix> sym('2*a', [2 3])
%!error <Cannot create symbolic matrix> sym(2*sym('a'), [2 3])
%!error <Cannot create symbolic matrix> sym('1', [2 3])
%!error <Cannot create symbolic matrix> sym(1, [2 3])

%!error <Cannot create symbolic matrix>
%! % TODO: symbolic tensor, maybe supported someday
%! sym('a', [2 3 4])

%!test
%! % 50 shapes of empty
%! a = sym (ones (0, 3));
%! assert (isa (a, 'sym'))
%! assert (isequal (size (a), [0 3]))
%! a = sym (ones (2, 0));
%! assert (isequal (size (a), [2 0]))
%! a = sym ([]);
%! assert (isequal (size (a), [0 0]))

%!test
%! % moar empty
%! a = sym ('a', [0 3]);
%! assert (isa (a, 'sym'))
%! assert (isequal (size (a), [0 3]))
%! a = sym ('a', [2 0]);
%! assert (isa (a, 'sym'))
%! assert (isequal (size (a), [2 0]))

%!test
%! % embedded sympy commands, various quotes, issue #143
%! a = sym ('a');
%! a1 = sym ('Symbol("a")');
%! a2 = sym ('Symbol(''a'')');
%! assert (isequal (a, a1))
%! assert (isequal (a, a2))
%! % Octave only, and eval to hide from Matlab parser
%! if exist ('OCTAVE_VERSION', 'builtin')
%!   eval( 'a3 = sym("Symbol(''a'')");' );
%!   eval( 'a4 = sym("Symbol(\"a\")");' );
%!   assert (isequal (a, a3))
%!   assert (isequal (a, a4))
%! end

%!test
%! % complex
%! x = sym(1 + 2i);
%! assert (isequal (x, sym(1)+sym(2)*1i))

%!test
%! % doubles bigger than int32 INTMAX should not fail
%! d = 4294967295;
%! a = sym (d);
%! assert (isequal (double (a), d))
%! d = d + 123456;
%! a = sym (d);
%! assert (isequal (double (a), d))

%!test
%! % int32 integer types
%! a = sym (100);
%! b = sym (int32 (100));
%! assert (isequal (a, b))

%!test
%! % int32 MAXINT integers
%! a = sym ('2147483647');
%! b = sym (int32 (2147483647));
%! assert (isequal (a, b))
%! a = sym ('-2147483647');
%! b = sym (int32 (-2147483647));
%! assert (isequal (a, b))
%! a = sym ('4294967295');
%! b = sym (uint32 (4294967295));
%! assert (isequal (a, b))

%!test
%! % int64 integer types
%! a = sym ('123456789012345');
%! b = sym (int64(123456789012345));
%! c = sym (uint64(123456789012345));
%! assert (isequal (a, b))
%! assert (isequal (a, c))

%!test
%! % integer arrays
%! a = int64 ([1 2 100]);
%! s = sym (a);
%! assert (isequal (double (a), [1 2 100]))

%!test
%! % bigger int64 integer types
%! q = int64 (123456789012345);
%! w = 10000*q + 123;
%! a = sym ('1234567890123450123');
%! b = sym (w);
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
%! assert (~isempty (regexp (sympy (Eq), '^Symbol')))
%! assert (~isempty (regexp (sympy (Ei), '^Symbol')))

%!test
%! % more symbols with special sympy names
%! x = sym('FF');
%! assert (~isempty (regexp (x.pickle, '^Symbol')))
%! x = sym('ff');
%! assert (~isempty (regexp (x.pickle, '^Symbol')))

%!test
%! % E can be a sym not just exp(sym(1))
%! syms E
%! assert (~logical (E == exp(sym(1))))

%!warning <dangerous> sym (1e16);
%!warning <dangerous> sym (-1e16);
%!warning <dangerous> sym (10.33);
%!warning <dangerous> sym (-5.23);

%!error <is not supported>
%! x = sym ('x', 'positive2');

%!error <is not supported>
%! x = sym ('x', 'integer', 'positive2');

%!error <is not supported>
%! x = sym ('x', 'integer2', 'positive');

%!error <Only symbols can have assumptions>
%! x = sym ('-pi', 'positive')

%!error <Only symbols can have assumptions>
%! x = sym ('pi', 'integer')

%!test
%! % multiple assumptions
%! n = sym ('n', 'negative', 'even');
%! a = assumptions (n);
%! assert (strcmp (a, 'n: negative, even') || strcmp (a, 'n: even, negative'))

%!error <unexpected in assumptions>
%! % multiple assumptions as a list
%! % TODO: should this be allowed?
%! n = sym ('n', {'negative', 'even'});
%! a = assumptions (n);
%! assert (strcmp (a, 'n: negative, even') || strcmp (a, 'n: even, negative'))

%!error <unexpected in assumptions>
%! n = sym ('n', {{'negative', 'even'}});

%!test
%! % save/load sym objects
%! syms x
%! y = 2*x;
%! a = 42;
%! myfile = tempname ();
%! save (myfile, 'x', 'y', 'a')
%! clear x y a
%! load (myfile)
%! assert (isequal (y, 2*x))
%! assert (a == 42)
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   assert (unlink (myfile) == 0)
%! else
%!   delete ([myfile '.mat'])
%! end

%!test
%! a = sym ('2.1');
%! b = sym (21) / 10;
%! %% https://github.com/sympy/sympy/issues/11703
%! assert (python_cmd ('return _ins[0] == _ins[1] and hash(_ins[0]) == hash(_ins[1])', a, b))

%!test
%! % issue #706
%! a = sym('Float("1.23")');
%! assert (~ isempty (strfind (char (a), '.')))

% TODO: test that might be used in the future
%%!warning <avoid execute operations> sym ('1*2');

% TODO: test that might be used in the future
%%!warning <You are overloading/hiding> sym ('beta');

%!error <use another variable name> sym ('FF(w)');

%!warning <deprecated> sym({1 2});

%!test
%! % multiple syms with assumptions
%! % TODO: update this with #603
%! s = warning ('off', 'OctSymPy:deprecated');
%! q = sym ({'a', 'b', 'c'}, 'positive');
%! warning (s)
%! t = {};
%! t{1, 1} = 'a: positive';
%! t{1, 2} = 'b: positive';
%! t{1, 3} = 'c: positive';
%! assert (isequal (t, assumptions(q)))

%!test
%! a = sym ('--1');
%! b = sym ('---1');
%! assert (isequal (a, sym (1)))
%! assert (isequal (b, sym (-1)))

%!test
%! % num2cell works on sym arrays
%! syms x
%! C1 = num2cell ([x 2 3; 4 5 6*x]);
%! assert (iscell (C1))
%! assert (isequal (size (C1), [2 3]))
%! assert (isequal (C1{1,1}, x))
%! assert (isequal (C1{2,3}, 6*x))
%! assert (isequal (C1{1,3}, sym(3)))
%! assert (isa (C1{1,3}, 'sym'))
