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
%% @defmethod  @@sym findsym (@var{expr})
%% @defmethodx @@sym findsym (@var{expr}, @var{n})
%% Find symbols in expression, return them as comma-separated string.
%%
%% For details, @pxref{@@sym/symvar}; this just concatenates its output
%% into a string.
%%
%% Example:
%% @example
%% @group
%% syms y a b
%% f = a*y + b;
%% v = findsym (f)
%%   @result{} v = a,b,y
%% v = findsym (f, 1)
%%   @result{} v = y
%% @end group
%% @end example
%%
%% @seealso{@@sym/symvar, symvar, findsymbols}
%% @end defmethod


function s = findsym(varargin)

  A = symvar(varargin{:});

  s = strjoin(syms2charcells(A), ',');

end


function C = syms2charcells(S)
  C = {};
  for i=1:length(S)
    if iscell(S)
      C{i} = S{i}.flat;
    else
      % MoFo Issue #17
      %C{i} = S(i).flat
      idx.type = '()';
      idx.subs = {i};
      temp = subsref(S, idx);
      C{i} = temp.flat;
    end
  end
end


%!assert (strcmp (findsym (sym(2)), ''));

%!shared x,y,f
%! x=sym('x'); y=sym('y'); f=x^2+3*x*y-y^2;
%!assert (strcmp (findsym (f), 'x,y'));
%!assert (strcmp (findsym (f,1), 'x'));

%!test
%! % test order of returned vars
%! syms x y a b c xx
%! % https://www.mathworks.com/matlabcentral/newsreader/view_thread/237730
%! alpha = sym('alpha');
%! assert (strcmp (findsym(b*xx*exp(alpha) + c*sin(a*y), 2), 'xx,y'))
