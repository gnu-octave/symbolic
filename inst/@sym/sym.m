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

  % FIXME not careful enough with the x argument here?
  % for example, see lambda->lamda below
  if (nargin == 2)
    %disp('make w/ assumptions')
    asm = varargin{1};
    if (~ischar(x))
      error('invalid input');
    end
    if isstruct(asm) && isscalar(asm)
      % we have an assumptions dict
      cmd = sprintf('s = sympy.Symbol("%s", **_ins[0])\nreturn s,', x);
      s = python_cmd (cmd, asm);
      return
    elseif strcmp(asm, 'real')
      cmd = sprintf('z = sympy.Symbol("%s", real=True)', x);
    elseif strcmp(asm, 'positive')
      cmd = sprintf('z = sympy.Symbol("%s", positive=True)', x);
    elseif strcmp(asm, 'integer')
      cmd = sprintf('z = sympy.Symbol("%s", integer=True)', x);
    elseif strcmp(asm, 'even')
      cmd = sprintf('z = sympy.Symbol("%s", even=True)', x);
    elseif strcmp(asm, 'odd')
      cmd = sprintf('z = sympy.Symbol("%s", odd=True)', x);
    elseif strcmp(asm, 'rational')
      cmd = sprintf('z = sympy.Symbol("%s", rational=True)', x);
    elseif strcmp(asm, 'clear')
      error('Not implemented, Issue #37');
    else
      error('that assumption not supported')
    end
    s = python_cmd ([ cmd '\nreturn (z,)' ]);
    return
  end

  %% User interface for defining sym
  % sym(1), sym('x'), etc.

  % not a subclass, exactly a sym, not symfun
  %if (strcmp (class (x), 'sym'))
  if (isa (x, 'sym'))
    s = x;
    return

  elseif (iscell (x))
    s = cell_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isscalar (x) )
    s = double_array_to_sym (x);
    return

  elseif (isa (x, 'double')  &&  ~isreal (x) )
    s = sym(real(x)) + sym('I')*sym(imag(x));
    return

  elseif (isa (x, 'double'))
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
      % FIXME: good if this waring were configurable, personally I like
      % it to at least warn so I can catch bugs.
      % Matlab SMT also does this (w/o warning).
      % I don't trust this behaviour much.
      warning('Using rats() for rational approx, did you really mean to pass a noninteger?');
      s = sym(rats(x));
    end
    return


  elseif (isa (x, 'char'))
    if (strfind(x, '('))
      %% Start making an abstract symfun
      % If we see parentheses, we assume user is making a symfun.  We
      % don't do it directly here, but instead return a specially
      % tagged sym.  Essentially, the contents of this sym are
      % irrelevant except for the special contents of the "extra"
      % field.  subasgn can then note this and actually build the
      % symfun: it will know the arguments from the LHS of "g(x) =
      % sym('g(x)')".  If the user calls "g = sym('g(x)')", I see no
      % easy way to throw an error, so we just make the symbol itself
      % a plea to read the docs ;-)
      %disp('DEBUG: I hope you are using this sym for the rhs of a symfun...');
      s = sym('pleaseReadHelpSymFun');
      s.extra = {'MAKING SYMFUN HACK', x};
      %s = x;  % this would be nicer, but it fails to call subsasgn
      return
    end
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
    elseif (strcmp(x, 'beta')),   cmd = 'z = sympy.Symbol("beta")';
    elseif (strcmp(x, 'gamma')),  cmd = 'z = sympy.Symbol("gamma")';
    elseif (strcmp(x, 'zeta')),   cmd = 'z = sympy.Symbol("zeta")';
    elseif (strcmp(x, 'lambda')), cmd = 'z = sympy.Symbol("lamda")'; %not typo
    elseif (strcmp(x, 'Lambda')), cmd = 'z = sympy.Symbol("Lamda")'; %not typo
    elseif (strcmp(x, 'Chi')),    cmd = 'z = sympy.Symbol("Chi")';
    elseif (strcmp(x, 'S')),      cmd = 'z = sympy.Symbol("S")';  % possibly
    elseif (strcmp(x, 'N')),      cmd = 'z = sympy.Symbol("N")';  % a bad
    elseif (strcmp(x, 'Q')),      cmd = 'z = sympy.Symbol("Q")';  % idea!
    else
      if (~isempty((strfind(x, '.'))))
        warning('possibly unintended decimal point in constructor string');
      end
      cmd = sprintf('z = sp.S("%s")', x);
    end
  else
    x
    class(x)
    error('conversion from that type to symbolic not (yet) supported');
  end

  s = python_cmd ([ cmd '\nreturn (z,)' ]);

end


%!test
%! assert (isa (sym (pi), 'sym'))
%!assert (isa (sym ('beta'), 'sym'))
