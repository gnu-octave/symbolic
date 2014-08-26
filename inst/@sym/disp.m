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
%% @deftypefn  {Function File}  {} disp (@var{x})
%% @deftypefnx {Function File}  {@var{s} =} disp (@var{x})
%% Display the value of a symbolic expression.
%%
%% @seealso{pretty}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

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
      error('invalid display type')
  end
  s = make_indented(s);

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end
end


function s = make_indented(s, n)
  if (nargin == 1)
    n = 3;
  end
  pad = char (double (' ')*ones (1,n));
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
end


%!test
%! syms x
%! s = disp(sin(x));
%! assert(strcmp(s, '   sin(x)'))

%!test
%! syms x
%! s = disp(sin(x/2), 'flat');
%! assert(strcmp(s, '   sin(x/2)'))

%!test
%! % Examples of 2x0 and 0x2 empty matrices:
%! a = sym([1 2; 3 4]);
%! b2x0 = a([true true], [false false]);
%! b0x2 = a([false false], [true true]);
%! assert (size (b2x0), [2 0])
%! assert (size (b0x2), [0 2])
%! s = disp(b2x0);
%! assert(strcmp(s, '   []'))
%! s = disp(b0x2);
%! assert(strcmp(s, '   []'))
