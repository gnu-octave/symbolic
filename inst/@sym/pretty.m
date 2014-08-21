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
%% @deftypefn  {Function File}  {} pretty (@var{x})
%% @deftypefnx {Function File}  {@var{s} =} pretty (@var{x})
%% Return/display ASCII-art/unicode representation of expression.
%%
%% This is usually the same as @code{disp(x)}, unless you have
%% @code{octsympy_config display flat}, in which case
%% @code{pretty(x)} displays ASCII-art.  You can force unicode
%% with @code{pretty(x, 'unicode')}.
%%
%% Note: pretty(x) works like disp(x) (makes output even if has a
%% semicolon)
%%
%% @code{pretty} exists mainly for compatibility with the
%% Symbolic Math Toolbox.
%%
%% @seealso{disp, latex}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function varargout = pretty(x, wh)

  if (nargin == 1)
    % read config to see how to display x
    wh = octsympy_config('display');
  end

  % if config says flat, pretty does ascii
  if (strcmp('flat', lower(wh)))
    wh = 'ascii';
  end

  if (nargout == 0)
    disp(x, wh)
  else
    varargout{1} = disp(x, wh);
  end
end


%!test
%! % simple
%! syms x
%! s1 = pretty(sin(x));
%! s2 = '   sin(x)';
%! assert(strcmp(s1,s2))

%!test
%! % force ascii
%! syms x
%! s1 = pretty(sin(x/2), 'ascii');
%! s2 = sprintf('      /x\\\n   sin|-|\n      \\2/');
%! assert(strcmp(s1,s2))

%!test
%! % with unicode, probably fails on Matlab
%! syms x
%! s1 = pretty(sin(x/2));
%! s2 = sprintf('      ⎛x⎞\n   sin⎜─⎟\n      ⎝2⎠');
%! assert(strcmp(s1,s2))
