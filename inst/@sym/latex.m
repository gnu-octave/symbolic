%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {} latex (@var{x})
%% @deftypefnx {Function File}  {@var{s} =} latex (@var{x})
%% Return LaTeX typesetting code for a symbolic expression.
%%
%% Example:
%% @example
%% @group
%% >> syms x
%% >> latex(sin(x/2))
%%    @print{} \sin@{\left (\frac@{x@}@{2@} \right )@}
%%
%% >> A = [sym(1) 2; sym(3) 4];
%% >> s = latex(A)
%%    @result{} s = \left[\begin@{matrix@}1 & 2\\3 & 4\end@{matrix@}\right]
%% @end group
%% @end example
%%
%% @seealso{disp, pretty}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function varargout = latex(x)

  cmd = { 'return sp.latex(*_ins),' };

  s = python_cmd (cmd, x);

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end

end


%!test
%! syms x
%! y = sin(x);
%! assert ( strcmp( latex(y), '\sin{\left (x \right )}'))
%! assert ( strcmp( latex(exp(x)), 'e^{x}'))
