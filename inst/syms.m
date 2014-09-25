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
%% @deftypefn  {Function File} {} syms @var{x}
%% @deftypefnx {Function File} {} syms @var{f(x)}
%% @deftypefnx {Function File} {} syms
%% Create symbolic variables and symbolic functions.
%%
%% This is a convenience function.  For example:
%% @example
%% syms x y z
%% @end example
%% instead of:
%% @example
%% x = sym('x');
%% y = sym('y');
%% z = sym('z');
%% @end example
%%
%% The last argument can provide an assumption (type or
%% restriction) on the variable (@xref{sym}, for details.)
%% @example
%% syms x y z positive
%% @end example
%%
%% Symfun's represent abstract or concrete functions.  Abstract
%% symfun's can be created with @code{syms}:
%% @example
%% syms f(x)
%% @end example
%% If @code{x} does not exost in the callers workspace, it
%% is created as a @strong{side effect} in that workspace.
%%
%% Called without arguments, @code{syms} displays a list of
%% all symbolic functions defined in the current workspace.
%%
%% Caution: On Matlab, you may not want to use @code{syms} within
%% functions.
%%   In particular, if you shadow a function name, you may get
%%   hard-to-track-down bugs.  For example, instead of writing
%%   @code{syms alpha} use @code{alpha = sym('alpha')} in functions.
%%   [https://www.mathworks.com/matlabcentral/newsreader/view_thread/237730]
%%
%% @seealso{sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function syms(varargin)

  %% No inputs
  %output names of symbolic vars
  if (nargin == 0)
    S = evalin('caller', 'whos');
    disp('Symbolic variables in current scope:')
    for i=1:numel(S)
      %S(i)
      if strcmp(S(i).class, 'sym')
        disp(['  ' S(i).name])
      elseif strcmp(S(i).class, 'symfun')
        % FIXME improve display of symfun
        disp(['  ' S(i).name ' (symfun)'])
      end
    end
    return
  end

  % Check if final input is assumption
  asm = varargin{end};
  if ( strcmp(asm, 'real') || strcmp(asm, 'positive') || strcmp(asm, 'integer') || ...
       strcmp(asm, 'even') || strcmp(asm, 'odd') || strcmp(asm, 'rational') || ...
       strcmp(asm, 'clear') )
    last = nargin-1;
  else
    asm = '';
    last = nargin;
  end

  % loop over each input
  for i = 1:last
    expr = varargin{i};

    % look for parenthesis: check if we're making a symfun
    if (isempty (strfind (expr, '(') ))  % no
      assert(isvarname(expr)); % help prevent malicious strings
      if isempty(asm)
        assignin('caller', expr, sym(expr))
      elseif strcmp(asm, 'clear')
        % We do this here instead of calling sym() because sym()
        % would modify this workspace instead of the caller's.
        newx = sym(expr);
        assignin('caller', expr, newx);
        xstr = newx.flat;
        % ---------------------------------------------
        % Muck around in the caller's namespace, replacing syms
        % that match 'xstr' (a string) with the 'newx' sym.
        %xstr = x;
        %newx = s;
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
      else
        assignin('caller', expr, sym(expr, asm))
      end

    else  % yes, this is a symfun
      assert(isempty(asm), 'mixing symfuns and assumptions not supported')
      tok = mystrsplit(varargin{i}, {'(', ')', ','});
      name = strtrim(tok{1});
      vars = {};  varnames = {};  c = 0;
      for i = 2:length(tok)
        vs = strtrim(tok{i});
        if ~isempty(vs)
          assert(isvarname(vs)); % help prevent malicious strings
          exists = evalin('caller',['exist(''' vs ''', ''var'')']);
          if (exists)
            vs_sym = evalin('caller', vs);
          else
            vs_sym = sym(vs);
            assignin('caller', vs, vs_sym);
          end
          c = c + 1;
          vars{c} = vs_sym;;
          varnames{c} = vs;
        end
      end
      sf = symfun(name, vars);
      assignin('caller', name, sf);
    end

  end

end


%!test
%! %% assumptions
%! syms x real
%! x2 = sym('x', 'real');
%! assert (isequal (x, x2))

%!test
%! %% assumptions and clearing them
%! syms x real
%! f = {x {2*x}};
%! A = assumptions();
%! assert ( ~isempty(A))
%! syms x clear
%! A = assumptions();
%! assert ( isempty(A))

%!test
%! %% matlab compat, syms x clear should add x to workspace
%! syms x real
%! f = 2*x;
%! clear x
%! assert (~logical(exist('x', 'var')))
%! syms x clear
%! assert (logical(exist('x', 'var')))
