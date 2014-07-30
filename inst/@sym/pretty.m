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
%% Return/display ASCII-art representation of symbolic expression.
%%
%% Note: pretty(x) works like disp(x) (makes output even if has a
%% semicolon)
%%
%% FIXME: octsympy_config...
%% FIXME: wrapping column?
%% FIXME: store this in the sym?  pretty_by_default?  flat versus not?
%%
%% @seealso{disp,latex}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function varargout = pretty(x, opt)

  loose = strcmp(get(0,'FormatSpacing'), 'loose');

  if nargin == 1
    opt = 0;
  end
  if opt
    cmd = [ 'd = sp.pretty(*_ins, use_unicode=False)\n'  ...
            'return (d,)' ];
  else
    cmd = [ 'd = sp.pretty(*_ins, use_unicode=True)\n'  ...
            'return (d,)' ];
  end

  s = python_cmd (cmd, x);

  if (nargout == 0)
    if (loose), fprintf ('\n'); end
    print_indented (s)
    if (loose), fprintf ('\n'); end
  else
    varargout = {s};
  end
end

function print_indented(s, n)
  if (nargin == 1)
    n = 3;
  end
  pad = char (double (' ')*ones (1,n));
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
  disp(s)
end


%!test
%! % simple
%! syms x
%! s1 = pretty(sin(x));
%! s2 = 'sin(x)';
%! assert(strcmp(s1,s2))

%!test
%! % with unicode, probably fails on Matlab
%! syms x
%! s1 = pretty(sin(x/2));
%! s2 = sprintf('   ⎛x⎞\nsin⎜─⎟\n   ⎝2⎠');
%! assert(strcmp(s1,s2))
