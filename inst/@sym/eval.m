%% Copyright (C) 2019 Colin B. Macdonald
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
%% @defmethod @@sym eval (@var{f})
%% Symbolic expression to double, taking values from workspace.
%%
%% For expressions without symbols, @code{eval} does the same thing
%% as @code{double}:
%% @example
%% @group
%% f = 2*sin(sym(3))
%%   @result{} f = (sym) 2⋅sin(3)
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% eval(f)
%%   @result{} ans = 0.2822
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% double(f)
%%   @result{} ans = 0.2822
%% @end group
%% @end example
%%
%% For an expression containing symbols, @code{eval} looks in the
%% workspace for variables whose names match the symbols.  It then
%% evaluates the expression using the values from those variables.
%% For example:
%% @example
%% @group
%% syms x y
%% f = x*sin(y)
%%   @result{} f = (sym) x⋅sin(y)
%% @end group
%%
%% @group
%% x = 2.1
%%   @result{} x = 2.1000
%% y = 2.9
%%   @result{} y = 2.9000
%% @end group
%%
%% @group
%% f
%%   @result{} f = (sym) x⋅sin(y)
%%
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% eval(f)
%%   @result{} ans = 0.5024
%% @end group
%% @end example
%%
%% @seealso{@@sym/subs}
%% @end defmethod


function g = eval(f)

  if (nargin ~= 1)
    print_usage ();
  end

  %% take values of x from the workspace
  in = findsymbols (f);
  out = {};
  i = 1;
  while (i <= length (in))
    xstr = char (in{i});
    try
      xval = evalin ('caller', xstr);
      foundit = true;
    catch
      foundit = false;
    end
    if (foundit)
      out{i} = xval;
      i = i + 1;
    else
      in(i) = [];  % erase that input
    end
  end

  try
    %% Fails if the workspace doesn't have values for all symbols.
    % Could also fail for fcns with broken "roundtrip"
    fh = function_handle(f, 'vars', in);
    g = fh(out{:});
    return
  catch
    % no-op
  end

  %% Instead, try substituting and converting to double.
  g = subs (f, in, out);
  try
    g = double (g);
  catch
    % just g then
  end

end


%!error <Invalid> eval (sym(1), 2)

%!assert (isnumeric (eval (sym(3))))
%!assert (isnumeric (eval (sin (sym(3)))))

%!test
%! syms x y
%! f = 2*x*y;
%! x = 3;
%! y = 4;
%! g = eval (f);
%! assert (isequal (g, 24))

%!test
%! syms x y
%! f = 2*x*y;
%! clear y
%! x = 3;
%! g = eval (f);
%! assert (isequal (g, 6*sym('y')))

%!test
%! % do not convert inputs to sym, for SMT compat
%! nearpi = pi + 1e-14;  % sym could make this pi
%! x = sym('x');
%! f = 2*x;
%! x = nearpi;
%! d = eval (f);
%! assert (abs (d - 2*pi) > 1e-15)
