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
%% @deftypefn  {Function File} {@var{S} =} findsym (@var{expr})
%% @deftypefnx {Function File} {@var{S} =} findsym (@var{expr}, @var{n})
%% Find symbols in expression, return them as comma-separated string.
%%
%% See @code{symvar}, this just concatenates its output into a
%% string.
%%
%% Example:
%% @example
%% syms y,a,b
%% vars  = findsym (f);     % outputs 'a,b,y'
%% vars2 = findsym (f,1);   % outputs 'y'
%% @end example
%%
%% @seealso{symvar, findsymbols}
%% @end deftypefn

function s = findsym(varargin)

  A = symvar(varargin{:});

  % FIXME: once Octave 3.6 is ancient history, use strjoin
  s = mystrjoin(syms2charcells(A), ',');

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
