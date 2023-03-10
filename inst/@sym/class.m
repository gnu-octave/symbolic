%% Copyright (C) 2016 Abhinav Tripathi and Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
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
%% @deftypemethod  @var{c} = class (@var{x})
%% @deftypemethodx @var{c} = class (@var{x}, @var{full})
%% Return class name of the variable x.
%%
%% @var{full} decides if the fully qualified class name will be returned
%% or not. It it true by default. 
%%
%% Example:
%% @example
%% @group
%% syms x
%% class(x)
%%   @result{} ans = sympy.core.symbol.Symbol
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms x
%% class(x, false)
%%   @result{} ans = Symbol
%% @end group
%% @end example
%%
%% @end deftypemethod

function cname = class(x, full)

  if (nargin > 2 || (nargin == 2 && !islogical(full)))
    print_usage ();
  end
  
  if (nargin == 1)
    full = true;
  end

  % TODO: if the ipc is pytave then return @pyobject instead
  cmd = { '(x,f) = _ins'
          'return (x.__module__ + "." if f else "") + x.__class__.__name__'
        };

  cname = python_cmd (cmd, x, full);
end


%!error <Invalid> class (sym(1), true, 3)
%!error <Invalid> class (sym(1), 2)

%!test
%! syms x y
%! assert (class(x), 'sympy.core.symbol.Symbol')
%! assert (class(x), class(x, true))
%! assert (class(x), class(y))

%!assert (class (sym (1)), 'sympy.core.numbers.One')
%!assert (class (sym (1), false), 'One')

%!assert (class (sym (1000)), 'sympy.core.numbers.Integer')
%!assert (class (cos (sym (1))), 'sympy.functions.elementary.trigonometric.cos')
