%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @deftypemethod  @@sym  {} pretty (@var{x})
%% @deftypemethodx @@sym  {@var{s} =} pretty (@var{x})
%% @deftypemethodx @@sym  {@var{s} =} pretty (@var{x}, 'unicode')
%% @deftypemethodx @@sym  {@var{s} =} pretty (@var{x}, 'ascii')
%% Return/display unicode/ascii-art representation of expression.
%%
%% By default, this is similar to @code{disp(x)}:
%% @example
%% @group
%% syms n
%% pretty (ceil (pi/n));
%%   @print{}   ⎡π⎤
%%   @print{}   ⎢─⎥
%%   @print{}   ⎢n⎥
%% @end group
%% @end example
%%
%% However, if you set @code{sympref display ascii}, @code{pretty(x)}
%% displays ascii-art instead.  The optional second argument forces
%% the output:
%% @example
%% @group
%% pretty (ceil (pi/n), 'ascii');
%%   @print{}          /pi\
%%   @print{}   ceiling|--|
%%   @print{}          \n /
%% @end group
%% @end example
%%
%% This method might be useful if you usually prefer
%% @code{sympref display flat} but occasionally want to pretty
%% print an expression.
%%
%% @seealso{@@sym/disp, @@sym/latex}
%% @end deftypemethod


function varargout = pretty(x, wh)

  if (nargin == 1)
    % read config to see how to display x
    wh = sympref('display');
  end

  % if config says flat, pretty does unicode
  if (strcmp('flat', lower(wh)))
    if (ispc () && (~isunix ()))
      % Unicode not working on Windows, Issue #83.
      wh = 'ascii';
    else
      wh = 'unicode';
    end
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
%! s2 = sprintf('  sin(x)\n');
%! assert (strcmp (s1, s2))

%!test
%! % force ascii
%! syms x
%! s1 = pretty(sin(x/2), 'ascii');
%! s2 = sprintf('     /x\\\n  sin|-|\n     \\2/\n');
%! swin = strrep(s1, sprintf('\r\n'), sprintf('\n'));
%! assert (strcmp (s1, s2) || strcmp (swin, s2))

%!test
%! % force unicode
%! syms x
%! s1 = pretty(sin(x/2), 'unicode');
%! s2 = sprintf('     ⎛x⎞\n  sin⎜─⎟\n     ⎝2⎠\n');
%! swin = strrep(s1, sprintf('\r\n'), sprintf('\n'));
%! assert (strcmp (s1, s2) || strcmp (swin, s2))
