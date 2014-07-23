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
%% @deftypefn {Function File} {@var{r} =} isequaln (@var{f}, @var{g})
%% Test if two symbolic arrays are same.
%%
%% Here @code{nan == nan} is true, see also @code{isequal} where
%% @code{nan ~= nan}.
%%
%% @seealso{logical, isAlways, eq (==), isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function t = isequaln(x,y,varargin)


  %% some special cases
  if ~(is_same_shape(x,y))
    t = false;
    return
  end

  % at least on sympy 0.7.4, 0.7.5, nan == nan is true so we
  % don't need to detect it ourselves (todo: this seems a bit
  % fragile to rely on!)

  % sympy's == is not componentwise so no special case for arrays

  cmd = 'return (_ins[0] == _ins[1],)';

  t = python_cmd (cmd, sym(x), sym(y));

  if (~ islogical(t))
    error('nonboolean return from python');
  end

  %else  % both are arrays
  %  t = logical(zeros(size(x)));
  %  for j = 1:numel(x)
  %    % Bug #17
  %    idx.type = '()';
  %    idx.subs = {j};
  %    t(j) = isequaln(subsref(x,idx),subsref(y,idx));
  %  end
  %end

  if (nargin >= 3)
    t = t & isequaln(x, varargin{:});
  end

end


%!test
%! a = sym([1 2]);
%! b = a;
%! assert (isequaln (a, b))
%! b(1) = 42;
%! assert (~isequaln (a, b))

%!test
%! a = sym([1 2; 3 4]);
%! b = a;
%! assert (isequaln (a, b))
%! b(1) = 42;
%! assert (~isequaln (a, b))

%!test
%! a = sym([nan; 2]);
%! b = a;
%! assert (isequaln (a, b))

%!test
%! a = sym([nan 2; 3 4]);
%! b = a;
%! assert (isequaln (a, b))
