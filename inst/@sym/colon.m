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
%% @deftypefn  {Function File} {@var{x}} colon (@var{a},@var{b})
%% @deftypefnx {Function File} {@var{x}} colon (@var{a},@var{step},@var{b})
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
    step = 1;
  end

  % make sure inputs convert without error
  tilde = double(a);
  tilde = double(b);
  tilde = double(step);

  % much faster (for ipc) in python
  %y = sym( double(a):double(step):double(b) );
  evalpy('y = range(a,b+sign(step)*1,step);;', a, b, step);
  % FIXME: if evalpy learned arrays, could drop this...
  y = cell2mat(y);
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
%! % should be an error if it doesn't convert to double
%! syms x
%! try
%!   a = 1:x;
%!   waserr = false;
%! catch
%!   waserr = true;
%! end
%! assert(waserr)
