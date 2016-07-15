%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} max (@var{a})
%% @deftypemethodx @@sym {} max (@var{a}, @var{b})
%% @deftypemethodx @@sym {} max (@var{a}, [], @var{dim})
%% @deftypemethodx @@sym {[@var{r}, @var{I}] =} max (@dots{})
%% Return maximum value of a symbolic vector or vectors.
%%
%% Example:
%% @example
%% @group
%% max(sym(1), sym(2))
%%   @result{} (sym) 2
%% max([1 2*sym(pi) 6])
%%   @result{} (sym) 2⋅π
%% [M, I] = max([1 2*sym(pi) 6])
%%   @result{} M = (sym) 2⋅π
%%   @result{} I = 2
%% @end group
%% @end example
%%
%% @seealso{@@sym/min}
%% @end deftypemethod


function [z, I] = max(A, B, dim)

  if (nargin == 1)
    [z, I] = min(-A);
    z = -z;
  elseif (nargin == 2) && (nargout <= 1)
    z = -min(-A, -B);
  elseif (nargin == 3)
    [z, I] = min(-A, -B, dim);
    z = -z;
  else
    print_usage ();
  end

end


%% many other tests are in @sym/min

%!test
%! % simple
%! assert (isequal (max([sym(10) sym(11)]), sym(11)))
