%% Copyright (C) 2014-2016, 2018-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} disp (@var{x})
%% @deftypemethodx @@sym {} disp (@var{x}, 'unicode')
%% @deftypemethodx @@sym {} disp (@var{x}, 'ascii')
%% @deftypemethodx @@sym {} disp (@var{x}, 'flat')
%% @deftypemethodx @@sym {@var{s} =} disp (@var{x})
%% Display the value of a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% syms x a c
%% str = disp(sin(2*sym(pi)*x))
%%   @result{} str =   sin(2⋅π⋅x)
%%
%% A = [sin(x/2) floor(a^(x*c)); acosh(2*x/pi) ceil(sin(x/gamma(x)))];
%% disp(A, 'unicode')
%%   @print{}   ⎡     ⎛x⎞      ⎢ c⋅x⎥   ⎤
%%   @print{}   ⎢  sin⎜─⎟      ⎣a   ⎦   ⎥
%%   @print{}   ⎢     ⎝2⎠               ⎥
%%   @print{}   ⎢                       ⎥
%%   @print{}   ⎢     ⎛2⋅x⎞  ⎡   ⎛ x  ⎞⎤⎥
%%   @print{}   ⎢acosh⎜───⎟  ⎢sin⎜────⎟⎥⎥
%%   @print{}   ⎣     ⎝ π ⎠  ⎢   ⎝Γ(x)⎠⎥⎦
%% @end group
%%
%% @group
%% disp(A, 'ascii')
%%   @print{}   [     /x\              / c*x\      ]
%%   @print{}   [  sin|-|         floor\a   /      ]
%%   @print{}   [     \2/                          ]
%%   @print{}   [                                  ]
%%   @print{}   [     /2*x\         /   /   x    \\]
%%   @print{}   [acosh|---|  ceiling|sin|--------||]
%%   @print{}   [     \ pi/         \   \Gamma(x)//]
%%
%% disp(A, 'flat')
%%   @print{} Matrix([[sin(x/2), floor(a**(c*x))], [acosh(2*x/pi), ceiling(sin(x/gamma(x)))]])
%% @end group
%% @end example
%%
%% @seealso{@@sym/pretty}
%% @end deftypemethod


function varargout = disp(x, wh)

  if (nargin == 1)
    %% read config to see how to display x
    wh = sympref('display');
  end

  switch lower(wh)
    case 'flat'
      s = x.flat;
    case 'ascii'
      s = x.ascii;
    case 'unicode'
      s = x.unicode;
    otherwise
      print_usage ();
  end
  s = make_indented(s);

  if (nargout == 0)
    disp(s)
  else
    varargout = {[s sprintf('\n')]};  % add a newline
  end
end


function s = make_indented(s, n)
  if (nargin == 1)
    n = 2;
  end
  pad = char (double (' ')*ones (1,n));
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
end


%!test
%! syms x
%! s = disp(sin(x));
%! assert(strcmp(s, sprintf('  sin(x)\n')))

%!test
%! syms x
%! s = disp(sin(x/2), 'flat');
%! assert(strcmp(s, sprintf('  sin(x/2)\n')))

%!test
%! % Examples of 2x0 and 0x2 empty matrices:
%! a = sym([1 2; 3 4]);
%! b2x0 = a([true true], [false false]);
%! b0x2 = a([false false], [true true]);
%! assert (isequal (size (b2x0), [2 0]))
%! assert (isequal (size (b0x2), [0 2]))
%! s = disp(b2x0);
%! assert(strcmp(s, sprintf('  []\n')))
%! s = disp(b0x2);
%! assert(strcmp(s, sprintf('  []\n')))
