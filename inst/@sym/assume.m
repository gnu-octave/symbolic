%% Copyright (C) 2014-2017 Colin B. Macdonald
%% Copyright (C) 2017 Lagu
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
%% @deftypemethodx @@sym {@var{x} =} assume (@var{x}, 'clear')
%% @deftypemethodx @@sym {[@var{x}, @var{y}] =} assume ([@var{x} @var{y}], @dots{})
%% @deftypemethodx @@sym {} assume (@var{x}, @var{cond}, @var{cond2}, @dots{})
%% @deftypemethodx @@sym {} assume (@var{x}, 'clear')
%% @deftypemethodx @@sym {} assume ([@var{x} @var{y}], @dots{})
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
%% To clear assumptions on a variable use @code{assume(x, 'clear')}, for example:
%% @example
%% @group
%% syms x positive
%% f = sin (x);
%% assume (x, 'clear')
%% isempty (assumptions (f))
%%   @result{} ans = 1
%% @end group
%% @end example
%%
%% @strong{Warning}: the second form operates on the caller's
%% workspace via evalin/assignin.  So if you call this from other
%% functions, it will operate in your function's workspace (and not
%% the @code{base} workspace).  This behaviour is for compatibility
%% with other symbolic toolboxes.
%%
%% FIXME: idea of rewriting all sym vars is a bit of a hack, not
%% well tested (for example, with global vars.)
%%
%% @seealso{@@sym/assumeAlso, assume, assumptions, sym, syms}
%% @end deftypemethod


function varargout = assume(xx, varargin)

  assert (nargin > 1, 'assume: general algebraic assumptions are not supported');

  for n = 2:nargin
    assert (ischar (varargin{n-1}), 'assume: conditions should be specified as strings')
  end

  for i = 1:numel (xx)
    x = subsref (xx, substruct('()', {i}));
    xstr = x.flat;

    if (nargin > 1 && strcmp(varargin{1}, 'clear'))
      assert (nargin == 2, 'assume: clear cannot be combined with other assumptions')
      newx = sym(xstr);
    else
      for n = 2:nargin
        cond = varargin{n-1};
        ca.(cond) = true;
      end
      newx = sym(xstr, ca);
    end

    if (nargout > 0)
      varargout{i} = newx;
    else

      % ---------------------------------------------
      % Muck around in the caller's namespace, replacing syms
      % that match 'xstr' (a string) with the 'newx' sym.
      %xstr =
      %newx =
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

    end
  end
end


%!test
%! syms x
%! x = assume(x, 'positive');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive'))
%! x = assume(x, 'even');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: even'))
%! x = assume(x, 'odd');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: odd'))

%!error <strings>
%! syms x
%! x = assume (x, x);

%!error <Only symbols>
%! syms x
%! x = assume (x/pi, 'integer')

%!test
%! % multiple assumptions
%! syms x
%! x = assume(x, 'positive', 'integer');
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)

%!test
%! % multiple assumptions
%! syms x
%! x = assume(x, 'even', 'positive');
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.even)
%! assert(a{1}.positive)

%!test
%! % has output so avoids workspace
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! x = assume(x, 'negative');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: negative'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: positive'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: positive'))

%!test
%! % clear: has output so avoids workspace
%! syms x positive
%! f = 2*x;
%! x2 = assume(x, 'clear');
%! assert (~ isempty (assumptions (f)));

%!test
%! % has no output so does workspace
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! assume(x, 'negative');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: negative'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: negative'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: negative'))

%!test
%! % clear: has not output so does workspace
%! syms x positive
%! f = 2*x;
%! assume(x, 'clear');
%! assert (isempty (assumptions (f)));
%! assert (isempty (assumptions ()));

%!test
%! syms x positive
%! assume (x, 'clear')
%! assert (isempty (assumptions ()))

%!error <cannot be combined>
%! syms x
%! x2 = assume (x, 'clear', 'real');

%!error <algebraic assumptions are not supported>
%! syms a
%! assume (a > 0)

%!test
%! syms x y
%! assume ([x y], 'real')
%! assert (strcmp (assumptions (x), 'x: real'))
%! assert (strcmp (assumptions (y), 'y: real'))

%!test
%! syms x y
%! assume ([x y], 'positive', 'even')
%! assert (strcmp (assumptions (x), 'x: positive, even') || strcmp (assumptions (x), 'x: even, positive'))
%! assert (strcmp (assumptions (y), 'y: positive, even') || strcmp (assumptions (y), 'y: even, positive'))

%!test
%! % with output, original x and y are unchanged
%! syms x y
%! [p, q] = assume ([x y], 'real');
%! assert (isempty (assumptions (x)))
%! assert (isempty (assumptions (y)))
%! assert (strcmp (assumptions (p), 'x: real'))
%! assert (strcmp (assumptions (q), 'y: real'))

%!test
%! % matrix input
%! syms a b c d
%! assume ([a b; c d], 'real')
%! assert (strcmp (assumptions (a), 'a: real'))
%! assert (strcmp (assumptions (b), 'b: real'))
%! assert (strcmp (assumptions (c), 'c: real'))
%! assert (strcmp (assumptions (d), 'd: real'))
