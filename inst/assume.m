%% Copyright (C) 2017 Colin B. Macdonald
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
%% @deffn  Command assume {@var{x} @var{cond}}
%% @deffnx Command assume {@var{x} @var{cond} @var{cond2} @dots{}}
%% @deffnx Command assume {@var{x} @var{y} @dots{} @var{cond} @var{cond2} @dots{}}
%% Specify assumptions for a symbolic variable (replace existing).
%%
%% Example:
%% @example
%% @group
%% syms n x y
%% assume n integer
%% assume x y real
%% assumptions
%%   @result{} ans =
%%     @{
%%       [1,1] = n: integer
%%       [1,2] = x: real
%%       [1,3] = y: real
%%     @}
%% @end group
%% @end example
%%
%% To clear assumptions on a variable, use @code{assume x clear}, for example:
%% @example
%% @group
%% assume x y clear
%% assumptions
%%   @result{} ans =
%%     @{
%%       [1,1] = n: integer
%%     @}
%% @end group
%% @end example
%%
%% For more precise control over assumptions, @pxref{@@sym/assume}
%% and @pxref{@@sym/assumeAlso}.
%%
%% @seealso{@@sym/assume, @@sym/assumeAlso, assumptions, sym, syms}
%% @end deffn


function assume(varargin)

  assert (nargout == 0, 'assume: use functional form if you want output');

  assert (nargin > 1, 'assume: general algebraic assumptions are not supported');

  %% Find symbol/assumptions boundary and verify input
  valid_asm = assumptions ('possible');
  lastvar = -1;
  for n = 1:nargin
    assert (ischar (varargin{n}), 'assume: command form expects string inputs only')
    if (ismember (varargin{n}, valid_asm))
      if (lastvar < 0)
        lastvar = n - 1;
      end
    elseif (strcmp (varargin{n}, 'clear'))
      assert (n == nargin, 'assume: "clear" should be the final argument')
      assert (lastvar < 0, 'assume: should not combine "clear" with other assumptions')
      lastvar = n - 1;
    elseif (lastvar > 0)
      error('assume: cannot have symbols after assumptions')
    else
      assert (isvarname (varargin{n}), 'assume: only symbols can have assumptions')
    end
  end

  if (lastvar < 0)
    error ('assume: no assumptions were given')
  end
  if (lastvar == 0)
    error ('assume: cannot have only assumptions w/o symbols')
  end

  asm = varargin((lastvar+1):end);
  vars = varargin(1:lastvar);

  %% loop over each variable
  for n = 1:length (vars)
    vals = evalin ('caller', vars{n});
    newvals = cell(1, numel (vals));
    [newvals{:}] = assume (vals, asm{:});

    for i = 1:length (newvals)
      newx = newvals{i};
      xstr = newx.flat;

      % ---------------------------------------------
      % Muck around in the caller's namespace, replacing syms
      % that match 'xstr' (a string) with the 'newx' sym.
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


%!error <if you want output>
%! a = assume('a', 'real')

%!error <cannot have only assumptions>
%! assume positive integer

%!error <no assumptions>
%! assume x y

%!error <should be the final>
%! assume x clear real

%!error <algebraic assumptions are not supported>
%! assume a>0

%!error <only symbols>
%! assume 'x/pi' integer

%!test
%! syms x
%! assume x positive
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive'))
%! assume x even
%! a = assumptions(x);
%! assert(strcmp(a, 'x: even'))

%!test
%! % multiple assumptions
%! syms x
%! assume x positive integer
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)

%!test
%! % does workspace
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! assume x negative
%! a = assumptions(x);
%! assert(strcmp(a, 'x: negative'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: negative'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: negative'))

%!error <undefined>
%! % does not create new variable x
%! clear x
%! assume x real

%!error <undefined>
%! % no explicit variable named x
%! clear x
%! f = 2*sym('x');
%! assume x real

%!test
%! % clear does workspace
%! syms x positive
%! f = 2*x;
%! assume x clear
%! assert (isempty (assumptions (f)));
%! assert (isempty (assumptions ()));

%!test
%! syms x y
%! f = sin (2*x);
%! assume x y real
%! assert (strcmp (assumptions (x), 'x: real'))
%! assert (strcmp (assumptions (y), 'y: real'))
%! assert (strcmp (assumptions (f), 'x: real'))

%!test
%! syms x y
%! f = sin (2*x);
%! assume x y positive even
%! assert (strcmp (assumptions (x), 'x: positive, even') || strcmp (assumptions (x), 'x: even, positive'))
%! assert (strcmp (assumptions (y), 'y: positive, even') || strcmp (assumptions (y), 'y: even, positive'))
%! assert (strcmp (assumptions (f), 'x: positive, even') || strcmp (assumptions (f), 'x: even, positive'))

%!test
%! % works from variable names not symbols
%! syms x y
%! a = [x y];
%! assume a real
%! assert (strcmp (assumptions (x), 'x: real'))
%! assert (strcmp (assumptions (y), 'y: real'))

%!test
%! % works from variable names not symbols
%! y = sym('x');
%! f = 2*y;
%! assume y real
%! assert (strcmp (assumptions (f), 'x: real'))

%!test
%! % matrix of symbols
%! syms a b c d
%! A = [a b; c d];
%! assume A real
%! assert (strcmp (assumptions (a), 'a: real'))
%! assert (strcmp (assumptions (b), 'b: real'))
%! assert (strcmp (assumptions (c), 'c: real'))
%! assert (strcmp (assumptions (d), 'd: real'))

%!test
%! % assume after symfun
%! clear x
%! syms f(x)
%! assume x real
%! assert (~ isempty (assumptions (formula (f))))
%! assert (~ isempty (assumptions (argnames (f))))
