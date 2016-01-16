%% Copyright (C) 2016 Colin B. Macdonald and Lagu
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
%% @deftypefn {Function File}  {@var{r} =} intervals (@var{A})
%% @deftypefn {Function File}  {@var{r} =} intervals (@var{A}, @dots{})
%% Return a set of intervals.
%%
%% @seealso{union, intersect, setdiff, unique, ismember}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [varargout] = intervals(varargin)

  varargin = sym(varargin);
  e=0;

  while (iscell(varargin{1}))
    varargin = varargin{:};
    e=1;
  end

  cmd = {
         'x, = _ins'
         'for i in range(len(x)):'
         '    if isinstance(x[i], sp.Set):'
         '        pass'
         '    elif not isinstance(x[i], sp.MatrixBase):'
         '        x[i] = Interval(x[i], x[i])'
         '    elif len(x[i]) == 1:'
         '        x[i] = Interval(x[i], x[i])'
         '    else:'
         '        x[i]=Interval(*x[i])'
         'return x,'
        };

  if e
    [varargout{1:nargout}] = python_cmd (cmd, varargin);
  else
    varargout = python_cmd (cmd, varargin);
  end

end


%!test
%! [a, b]=intervals(sym(1), 1);
%! assert (isequal (a, b))

%!test
%! [a, b]=intervals(sym([1, 2]), [1, 2]);
%! assert (isequal (a, b))

%!test
%! [a, b]=intervals(sym([2, 1]), [4, 3]);
%! assert (isequal (a, b))
