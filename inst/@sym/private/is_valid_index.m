%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defun is_valid_index (@var{x})
%% Could the input in principle be used as an index.
%%
%% Note it doesn't check that its valid for any particular
%% indexing operation, just that its not too crazy (e.g.,
%% a non-integer).
%%
%% Specific things that are valid:
%% @itemize
%% @item strings @qcode{':'} and @qcode{'@w{}'}
%% @item empties such as @qcode{[]}
%% @item boolean
%% @item finite real integers
%% @end itemize
%% @end defun

function r = is_valid_index(x)

  if (ischar (x))
    r = strcmp (x, ':') || strcmp (x, '');
    return
  end

  if (isempty (x))
    r = true;
    return
  end

  if (islogical (x))
    r = true;
    return
  end

  % check that all are integers
  x = x(:);
  r = all (isreal (x) & isfinite (x) & (x == floor(x)));

end
