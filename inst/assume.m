%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{x} =} assume (@var{x}, @var{cond}, @var{cond2}, @dots{})
%% @deftypemethodx @@sym {} assume (@var{x}, @var{cond})
%% New assumptions on a symbolic variable (replace old if any).
%%
%% This function has two different behaviours depending on whether
%% it has an output argument or not.  The first form is simpler;
%% it returns a new sym with assumptions given by @var{cond}, for
%% example:
%% @example
%% @group
%% syms x
%% x1 = x;
%% x = assume(x, 'positive');
%% assumptions(x)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: positive
%%     @}
%% assumptions(x1)  % empty, x1 still has the original x
%%   @result{} ans = @{@}(0x0)
%% @end group
%% @end example
%%
%% Another example to help clarify:
%% @example
%% @group
%% x1 = sym('x', 'positive')
%%   @result{} x1 = (sym) x
%% x2 = assume(x1, 'negative')
%%   @result{} x2 = (sym) x
%% assumptions(x1)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: positive
%%     @}
%% assumptions(x2)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: negative
%%     @}
%% @end group
%% @end example
%%
%% You can negate an assumption with the false logical value:
%% @example
%% @group
%% x1 = sym('x', 'prime', false)
%%   @result{} x1 = (sym) x
%% x2 = assume(x1, 'commutative', false, 'polar')
%%   @result{} x2 = (sym) x
%% assumptions(x1)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: ~prime
%%     @}
%% assumptions(x2)        % doctest: +SKIP
%%   @result{} ans =
%%     @{
%%       [1,1] = x: polar, ~commutative
%%     @}
%% @end group
%% @end example
%%
%% To remove all assumptions of an expression use the 'clear' option
%% if the symbol don't exist in the workspace or don't have an output
%% it will be created in the workspace;
%% @example
%% @group
%% assume('x', 'clear');
%% x
%%   @result{} x = (sym) x
%% assumeAlso('x', 'positive');
%% assumptions(x)
%%   @result{} ans = 
%%     @{
%%         [1,1] = x: positive
%%     @}
%% assume('x', 'clear');
%% assumptions(x)
%%   @result{} ans = @{@}(0x0)
%% @end group
%% @end example
%%
%% The second form---with no output argument---is different; it
%% attempts to find @strong{all} instances of symbols with the same name
%% as @var{x} and replace them with the new version (with @var{cond}
%% assumptions).  For example:
%% @example
%% @group
%% syms x
%% x1 = x;
%% f = sin(x);
%% assume(x, 'positive');
%% assumptions(x)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: positive
%%     @}
%% assumptions(x1)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: positive
%%     @}
%% assumptions(f)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: positive
%%     @}
%% @end group
%% @end example
%%
%% @strong{Warning}: this second form operates on the caller's
%% workspace via evalin/assignin.  So if you call this from other
%% functions, it will operate in your function's workspace (and not
%% the @code{base} workspace).  This behaviour is for compatibility
%% with other symbolic toolboxes.
%%
%% FIXME: idea of rewriting all sym vars is a bit of a hack, not
%% well tested (for example, with global vars.)
%%
%% @seealso{@@sym/assumeAlso, assumptions, sym, syms}
%% @end deftypemethod

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function s = assume(x, varargin)

  if nargin == 0
    error ('Send an argument.')
  elseif nargin == 1
    error ('Not supported yet.')
  end

  varargin = norm_logic_strings (varargin);

  if isa (varargin{1}, 'char') && strcmp (varargin{1}, 'clear')

    % special case for 'clear', because of side-effects
    if isa (x, 'sym')
      x = x.flat;    % we just want the string
    end

    % ---------------------------------------------
    % Muck around in the caller's namespace, replacing syms
    % that match 'xstr' (a string) with the 'newx' sym.
    xstr = x;
    newx = sym (x);
    context = 'caller';
    % ---------------------------------------------
    S = evalin (context, 'whos');
    evalin (context, '[];');  % clear 'ans'

    if nargout == 0
      assignin (context, xstr, newx);
    else
      s = newx
    end

    for i = 1:numel (S)
      obj = evalin (context, S(i).name);
      [newobj, flag] = symreplace (obj, xstr, newx);
      if flag, assignin (context, S(i).name, newobj); end
    end
    % ---------------------------------------------
    return
  end

  for n=2:nargin
    if ~islogical (varargin{n - 1})
      cond = varargin{n - 1};
      if n < nargin && islogical (varargin{n})
        ca.(cond) = varargin{n};
      else
        ca.(cond) = true;
      end
    else
      if (n == 2 && islogical (varargin{1})) || islogical (varargin{n - 2})
        print_usage ();
      end
    end
  end

  if isa (x, 'sym')
    xstr = x.flat;
  else
    xstr = x;
  end

  newx = sym (xstr, ca);

  if (nargout > 0)
    s = newx;
    return
  else
    assignin ('caller', xstr, newx);
  end

  % ---------------------------------------------
  % Muck around in the caller's namespace, replacing syms
  % that match 'xstr' (a string) with the 'newx' sym.
  %xstr =
  %newx =
  context = 'caller';
  % ---------------------------------------------
  S = evalin (context, 'whos');
  evalin (context, '[];');  % clear 'ans'
  for i = 1:numel (S)
    obj = evalin (context, S(i).name);
    [newobj, flag] = symreplace (obj, xstr, newx);
    if flag, assignin (context, S(i).name, newobj); end
  end
  % ---------------------------------------------

end


%!test
%! syms x
%! x = assume (x, 'positive');
%! a = assumptions (x);
%! assert (strcmp (a, 'x: positive'))
%! x = assume (x, 'even');
%! a = assumptions (x);
%! assert (strcmp (a, 'x: even'))
%! x = assume (x, 'odd');
%! a = assumptions (x);
%! assert (strcmp (a, 'x: odd'))

%!test
%! syms x
%! x = assume (x, 'positive', false);
%! a = assumptions (x);
%! assert (strcmp (a, 'x: ~positive'))
%! x = assume (x, 'even', false);
%! a = assumptions (x);
%! assert (strcmp (a, 'x: ~even'))
%! x = assume (x, 'odd', false);
%! a = assumptions (x);
%! assert (strcmp (a, 'x: ~odd'))

%!test
%! % multiple assumptions
%! syms x
%! x = assume (x, 'positive', 'integer');
%! [tilde, a] = assumptions (x, 'dict');
%! assert (a{1}.integer)
%! assert (a{1}.positive)

%!test
%! % has output so avoids workspace
%! syms x positive
%! x2 = x;
%! f = sin (x);
%! x = assume (x, 'negative');
%! a = assumptions (x);
%! assert (strcmp (a, 'x: negative'))
%! a = assumptions (x2);
%! assert (strcmp (a, 'x: positive'))
%! a = assumptions (f);
%! assert (strcmp (a, 'x: positive'))

%!test
%! % has no output so does workspace
%! syms x positive
%! x2 = x;
%! f = sin (x);
%! assume (x, 'negative');
%! a = assumptions(x);
%! assert (strcmp(a, 'x: negative'))
%! a = assumptions(x2);
%! assert (strcmp(a, 'x: negative'))
%! a = assumptions(f);
%! assert (strcmp(a, 'x: negative'))

%!test
%! %% likewise for clear
%! x = sym ('x', 'real');
%! f = 2*x;
%! assume (x, 'clear');
%! assert (isempty (assumptions (x)))
%! assert (isempty (assumptions (f)))

%!test
%! %% matlab compat, syms x clear should add x to workspace
%! x = sym ('x', 'real');
%! f = 2*x;
%! clear x
%! assert (~logical (exist ('x', 'var')))
%! assume ('x', 'clear');
%! assert (logical (exist ('x', 'var')))

%!test
%! %% assumptions and clearing them
%! clear  % for matlab test script
%! x = sym ('x', 'real');
%! f = {x {2*x}};
%! asm = assumptions();
%! assert (~isempty (asm))
%! assume ('x', 'clear');
%! asm = assumptions();
%! assert (isempty (asm))

%!test
%! %% assumptions and clearing them
%! syms x real
%! f = {x {2*x}};
%! A = assumptions();
%! assert (~isempty (A))
%! assume x clear
%! A = assumptions();
%! assert (isempty (A))

%!test
%! x = assume ('x', 'positive');
%! a = assumptions (x);
%! assert (strcmp (a, 'x: positive'))

%!test
%! assume ('x', 'positive');
%! a = assumptions (x);
%! assert (strcmp (a, 'x: positive'))
