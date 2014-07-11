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
%% @deftypefn  {Function File} {@var{x} =} colon (@var{a},@var{b})
%% @deftypefnx {Function File} {@var{x} =} colon (@var{a},@var{step},@var{b})
%% Generate a range of syms.
%%
%% FIXME: should this generate intervals?  Check what SMT does?
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = colon(a,step,b)

  if (nargin == 2)
    b = step;
    step = sym(1);
  end
  a = sym(a);
  b = sym(b);
  step = sym(step);

  B = (b-a)/step;
  y = (0:double(B))*sym(step) + a;

  % this approach fails to  make 0:sym(pi):10
  %cmd = ['(a,b,step) = _ins\n'...
  %       'y = range(a,b+sign(step)*1,step)\n'...
  %       'return y,'];
  %y = python_cmd(cmd, a, b, step)
  %y = cell2mat(y);
end


%!test
%! a = sym(1):5;
%! b = sym(1:5);
%! assert(isequal(a,b));
%! a = 1:sym(5);
%! b = sym(1:5);
%! assert(isequal(a,b));

%!test
%! a = 2:sym(2):8;
%! b = sym(2:2:8);
%! assert(isequal(a,b));

%!test
%! a = sym(10):-2:-4;
%! b = sym(10:-2:-4);
%! assert(isequal(a,b));

%!test
%! % symbolic intervals
%! p = sym(pi);
%! L = 0:p/4:p;
%! assert(isa(L,'sym'));
%! assert(isequal(L, [0 p/4 p/2 3*p/4 p]));

%!test
%! % mixed symbolic and double intervals
%! p = sym(pi);
%! fprintf('\n*** 2 warnings expected: ***\n');
%! L = 0.1:(sym(pi)/3):2.3;
%! assert(isa(L,'sym'));
%! t = sym(1)/10;
%! assert(isequal(L, [t p/3+t 2*p/3+t]));

%!test
%! % should be an error if it doesn't convert to double
%! syms x
%! try
%!   a = 1:x;
%!   waserr = false;
%! catch
%!   waserr = true;
%! end
%! assert(waserr)
