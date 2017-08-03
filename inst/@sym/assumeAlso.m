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
%% @deftypemethod  @@sym {@var{x} =} assumeAlso (@var{x}, @var{cond}, @var{cond2}, @dots{})
%% @deftypemethodx @@sym {[@var{x}, @var{y}] =} assumeAlso ([@var{x} @var{y}], @var{cond}, @dots{})
%% @deftypemethodx @@sym {} assumeAlso (@var{x}, @var{cond})
%% @deftypemethodx @@sym {} assumeAlso ([@var{x} @var{y}], @var{cond}, @dots{})
%% Add additional assumptions on a symbolic variable.
%%
%% Behaviour is similar to @code{assume}; however @var{cond} is combined
%% with any existing assumptions of @var{x} instead of replacing them.
%%
%% Example:
%% @example
%% @group
%% syms x integer
%% x1 = x;
%% assumptions(x1)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: integer
%%     @}
%%
%% x = assumeAlso(x, 'positive');
%% assumptions(x)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: integer, positive
%%     @}
%% @end group
%% @end example
%%
%% As with @code{assume}, note @code{x1} is unchanged:
%% @example
%% @group
%% assumptions(x1)
%%   @result{} ans =
%%     @{
%%       [1,1] = x: integer
%%     @}
%% @end group
%% @end example
%%
%% @strong{Warning}: with no output argument, this tries to find
%% and replace any @var{x} within expressions in the caller's
%% workspace.  See @ref{assume}.
%%
%% @seealso{@@sym/assume, assumptions, sym, syms}
%% @end deftypemethod


function varargout = assumeAlso(xx, varargin)

  assert (nargin > 1, 'assumeAlso: general algebraic assumptions are not supported');

  for n = 2:nargin
    assert (ischar (varargin{n-1}), 'assumeAlso: conditions should be specified as strings')
  end

  for i = 1:numel (xx)
    x = subsref (xx, substruct('()', {i}));

    [tilde,ca] = assumptions(x, 'dict');

    if isempty(ca)
      ca = [];
    elseif (length(ca)==1)
      ca = ca{1};
    else
      ca
      error('expected at most one dict')
    end

    for n=2:nargin
      cond = varargin{n-1};
      ca.(cond) = true;
    end

    xstr = x.flat;
    newx = sym(xstr, ca);

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
%! x = assumeAlso(x, 'positive');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive'))

%!error <strings>
%! syms x
%! x = assumeAlso (x, x);

%!test
%! syms x positive
%! x = assumeAlso(x, 'integer');
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)

%!test
%! % multiple assumptions
%! syms x positive
%! x = assumeAlso(x, 'integer', 'even');
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)
%! assert(a{1}.even)

%!test
%! % multiple assumptions
%! syms x integer
%! x = assumeAlso (x, 'even', 'positive');
%! [tilde, a] = assumptions (x, 'dict');
%! assert (a{1}.integer)
%! assert (a{1}.even)
%! assert (a{1}.positive)

%!test
%! % has output so avoids workspace
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! assumeAlso(x, 'integer');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))

%!test
%! % has no output so does workspace
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! assumeAlso(x, 'integer');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))

%!error <algebraic assumptions are not supported>
%! syms a
%! assumeAlso (a > 0)

%!test
%! syms x y
%! assumeAlso ([x y], 'even')
%! assert (strcmp (assumptions (x), 'x: even'))
%! assert (strcmp (assumptions (y), 'y: even'))

%!test
%! syms x y positive
%! f = sin (2*x);
%! assumeAlso ([x y], 'even')
%! assert (strcmp (assumptions (x), 'x: even, positive') || strcmp (assumptions (x), 'x: positive, even'))
%! assert (strcmp (assumptions (y), 'y: even, positive') || strcmp (assumptions (y), 'y: positive, even'))
%! assert (strcmp (assumptions (f), 'x: even, positive') || strcmp (assumptions (f), 'x: positive, even'))

%!test
%! % with output, original x and y are unchanged
%! syms x y positive
%! f = sin (2*x);
%! [p, q] = assumeAlso ([x y], 'even');
%! assert (strcmp (assumptions (x), 'x: positive'))
%! assert (strcmp (assumptions (y), 'y: positive'))
%! assert (strcmp (assumptions (f), 'x: positive'))
%! assert (strcmp (assumptions (p), 'x: even, positive') || strcmp (assumptions (p), 'x: positive, even'))
%! assert (strcmp (assumptions (q), 'y: even, positive') || strcmp (assumptions (q), 'y: positive, even'))
