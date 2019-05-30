%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} latex (@var{x})
%% @deftypemethodx @@sym {@var{s} =} latex (@var{x})
%% Display or return LaTeX typesetting code for symbolic expression.
%%
%% Example:
%% @example
%% @group
%% syms x
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% latex(sin(x/2))
%%   @print{} \sin@{\left(\frac@{x@}@{2@} \right)@}
%% @end group
%%
%% @group
%% A = [sym(1) 2; sym(3) 4];
%% s = latex(A)
%%   @result{} s = \left[\begin@{matrix@}1 & 2\\3 & 4\end@{matrix@}\right]
%% @end group
%% @end example
%%
%% @seealso{@@sym/disp, @@sym/pretty}
%% @end deftypemethod


function varargout = latex(x)

  if (nargin ~= 1)
    print_usage ();
  end

  cmd = { 'return sp.latex(*_ins),' };

  s = pycall_sympy__ (cmd, x);

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end

end


%!test
%! syms x
%! y = sin(x);
%! if (pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%! assert (strcmp (latex (y), '\sin{\left(x \right)}'))
%! end

%!assert (strcmp (latex (exp (sym('x'))), 'e^{x}'))
