%% Copyright (C) 2014-2016, 2018 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} symreplace (@var{newx})
%% @deftypemethodx @@sym {} symreplace (@var{x}, @var{newx})
%% @deftypemethodx @@sym {} symreplace (@var{x}, @var{newx}, @var{context})
%% @deftypemethodx @@sym {} symreplace (@var{xstr}, @var{newx})
%% @deftypemethodx @@sym {} symreplace (@var{xstr}, @var{newx}, @var{context})
%% @deftypemethodx @@sym {[@var{f}, @var{flag}] =} symreplace (@var{f}, @var{xstr}, @var{newx})
%% Replace symbols in caller's workspace or in syms/struct/cells.
%%
%% @strong{WARNING}: you probably do not need this for normal
%% usage; @pxref{@@sym/subs} instead.
%%
%% One mode of operation is similar to @code{subs()}:
%% @example
%% @group
%% syms x y
%% f = @{x; 2*x; sin(x)@};
%% g = symreplace(f, x, y);
%% g@{:@}
%%   @result{} ans = (sym) y
%%   @result{} ans = (sym) 2⋅y
%%   @result{} ans = (sym) sin(y)
%% g = symreplace(f, 'x', y);   % alternative
%% @end group
%% @end example
%% However, unlike @code{subs()}, here @code{f} can be a cell array
%% or struct, which we recursively traverse down into.
%%
%% @var{flag} is true if the output @var{f} was changed from
%% the input @var{f}:
%% @example
%% @group
%% syms x y
%% f = sin(y);
%% [g, flag] = symreplace(f, x, y)
%%   @result{} g = (sym) sin(y)
%%   @result{} flag = 0
%% @end group
%% @end example
%%
%% The alternative form using @var{xstr} is used internally by
%% OctSymPy for assumptions (@pxref{@@sym/assume}, @pxref{@@sym/assumeAlso}),
%% to replace one @code{x} with another @code{x} with possibly
%% different assumptions.  For example:
%% @example
%% @group
%% syms x positive
%% f = x^2;
%% assumptions(f)@{:@}
%%   @result{} x: positive
%% x = sym('x', 'real');
%% f = symreplace(f, 'x', x);
%% assumptions(f)@{:@}
%%   @result{} x: real
%% @end group
%% @end example
%%
%% The other mode of operation is also used by OctSymPy for
%% supporting assumptions.  It has no output but plenty of
%% side-effects!  Not scared off yet?  Here's what it does:
%% @example
%% @group
%% syms x real
%% f = abs(x);
%% syms x positive
%% f
%%   @result{} f = (sym) │x│
%% symreplace ('x', x)
%% f
%%   @result{} f = (sym) x
%% @end group
%% @end example
%%
%% Here is the scary part: this works by searching expressions in
%% the @strong{callers workspace} for variables with same name as
%% @var{x}/@var{xstr}.  We then substitute @var{newx}.  If @var{x}
%% is omitted, the string of @var{newx} is used instead.  This is
%% precisely what happens when using @code{assume}:
%% @example
%% @group
%% syms x
%% f = abs(x);
%% assume(x, 'positive')
%% f
%%   @result{} f = (sym) x
%% @end group
%% @end example
%%
%% Note: operates on the caller's workspace via evalin/assignin.
%% So if you call this from other functions, it will operate in
%% your function's workspace (not the @code{base} workspace).
%% You can pass @code{'base'} to @var{context} to operate in
%% the base context instead.
%%
%% Note for developers: if you want to call this from your function
%% but have it work on the 'caller' context
%% @strong{of your function}, that unfortunately does not seem to
%% be possible.  Copy-paste the highlighted bits of this code into
%% your function instead (see @code{assume} for example).
%%
%% @seealso{@@sym/assume, @@sym/assumeAlso, assumptions, sym, syms}
%% @end deftypemethod


function varargout = symreplace(varargin)

  %% This is the first ("benign") form
  if ((nargout >= 1) || (nargin == 3 && ~ischar(varargin{3})))
    [varargout{1:2}] = symreplace_helper(varargin{:});
    return
  end

  %% otherwise, no output: this is the scary one
  if (nargin == 1)
    newx = varargin{1};
    xstr = newx.flat;
    context = 'caller';
  elseif (nargin == 2)
    xstr = varargin{1};
    newx = varargin{2};
    context = 'caller';
  elseif (nargin == 3)
    xstr = varargin{1};
    newx = varargin{2};
    context = varargin{3};
  else
    print_usage ();
  end

  assert(ischar(context) && ...
         (strcmp(context, 'caller') || strcmp(context, 'base')))

  % we just want the string
  if (isa(xstr, 'sym'))
    xstr = xstr.flat;
  end

  %% Here's the piece with side-effects
  % This is the part that you might want to copy into your function

  % ---------------------------------------------
  % Muck around in the caller's namespace, replacing syms
  % that match 'xstr' (a string) with the 'newx' sym.
  %xstr =
  %newx =
  %context = 'caller';
  S = evalin(context, 'whos');
  evalin(context, '[];');  % clear 'ans'
  for i = 1:numel(S)
    obj = evalin(context, S(i).name);
    [newobj, flag] = symreplace(obj, xstr, newx);
    if flag, assignin(context, S(i).name, newobj); end
  end
  % ---------------------------------------------

  %% end of side-effects bit

end



function [newobj, flag] = symreplace_helper(obj, xstr, newx)
% If you need to add other things other than struct/cell/sym, this is
% place to do it.

  if (isa (xstr, 'sym'))
    xstr = xstr.flat;
  end
  assert (ischar (xstr))

  flag = false;

  if isa (obj, 'symfun')
    sf_args = argnames (obj);
    sf_formula = formula (obj);
    [sf_args, flag1] = symreplace_helper(sf_args, xstr, newx);
    [sf_formula, flag2] = symreplace_helper(sf_formula, xstr, newx);
    if (flag1 || flag2)
      flag = true;
      newobj = symfun (sf_formula, sf_args);
    end

  elseif isa(obj, 'sym')
    % check if contains any symbols with the same string as x.
    symlist = findsymbols(obj);
    for c = 1:length(symlist)
      if strcmp(xstr, symlist{c}.flat)
        flag = true;
        break
      end
    end
    % If so, subs in the new x and replace that variable.
    if (flag)
      newobj = subs(obj, symlist{c}, newx);
    end

  elseif iscell(obj)
    %fprintf('Recursing into a cell array of numel=%d\n', numel(obj))
    newobj = obj;
    flag = false;
    for i=1:numel(obj)
      [temp, flg] = symreplace_helper(obj{i}, xstr, newx);
      if (flg)
        newobj{i} = temp;
        flag = true;
      end
    end

  elseif isstruct(obj)
    %fprintf('Recursing into a struct array of numel=%d\n', numel(obj))
    newobj = obj;
    fields = fieldnames(obj);
    for i=1:numel(obj)
      for j=1:length(fields)
        thisobj = getfield(obj, {i}, fields{j});
        [temp, flg] = symreplace_helper(thisobj, xstr, newx);
        if (flg)
          % This requires work on octave but not on matlab!  Instead, gratuitous
          % use of eval()...
          %newobj = setfield(newobj, {i}, fields{j}, temp);
          eval(sprintf('newobj(%d).%s = temp;', i, fields{j}));
          flag = true;
        end
      end
    end
  end

  if ~(flag)
    newobj = obj;
  end
end


%!test
%! % start with assumptions on x then remove them
%! syms x positive
%! f = x*10;
%! symreplace(x, sym('x'))
%! assert(isempty(assumptions(x)))

%!test
%! % replace x with y
%! syms x
%! f = x*10;
%! symreplace(x, sym('y'))
%! assert( isequal (f, 10*sym('y')))

%!test
%! % gets inside cells
%! syms x
%! f = {x 1 2 {3 4*x}};
%! symreplace(x, sym('y'))
%! syms y
%! assert( isequal (f{1}, y))
%! assert( isequal (f{4}{2}, 4*y))

%!test
%! % gets inside structs/cells
%! syms x
%! my.foo = {x 1 2 {3 4*x}};
%! my.bar = x;
%! g = {'ride'  my  'motor' 'sicle'};
%! symreplace(x, sym('y'))
%! syms y
%! f = g{2};
%! assert( isequal (f.foo{1}, y))
%! assert( isequal (f.foo{4}{2}, 4*y))
%! assert( isequal (f.bar, y))
