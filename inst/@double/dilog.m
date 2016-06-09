%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defun dilog (@var{x})
%% Numerical dilogarithm function
%%
%% Example:
%% @example
%% @group
%% dilog (1.1)
%%   @result{} ans = -0.097605
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the SymPy function
%% @code{polylog}.
%%
%% @seealso{@@sym/dilog}
%% @end defun


function y = dilog (x)
  if (nargin ~= 1)
    print_usage ();
  end
  cmd = { 'L = _ins[0]'
          'A = [complex(polylog(2, complex(1-x))) for x in L]'
          'return A,' };
  c = python_cmd (cmd, num2cell(x(:)));
  assert (numel (c) == numel (x))
  y = x;
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!test
%! x = 1.1;
%! y = sym(11)/10;
%! A = dilog (x);
%! B = double (dilog (y));
%! assert (A, B, -4*eps);

%!test
%! y = [2 2 sym(pi); exp(sym(1)) 5 6];
%! x = double (y);
%! A = dilog (x);
%! B = double (dilog (y));
%! assert (A, B, -eps);
