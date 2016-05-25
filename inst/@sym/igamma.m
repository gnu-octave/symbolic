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
%% @defmethod  @@sym igamma (@var{nu}, @var{x})
%% Symbolic upper incomplete gamma function.
%%
%% Example:
%% @example
%% @group
%% syms x nu
%% igamma (nu, x)
%%   @result{} (sym) Γ(ν, x)
%% @end group
%% @end example
%%
%% @strong{Note} the order of inputs is different from
%% @ref{@@sym/gammainc},
%% specifically:
%% @example
%% @group
%% igamma (nu, x)
%%   @result{} (sym) Γ(ν, x)
%% gammainc (x, nu, 'upper')
%%   @result{} (sym) Γ(ν, x)
%% @end group
%% @end example
%%
%% @seealso{@@sym/gammainc, @@sym/gamma}
%% @end defmethod

function y = igamma(a, z)
  if (nargin ~= 2)
    print_usage ();
  end

  y = gammainc(z, a, 'upper');
end


%!test
%! % mostly tested in @sym/gammainc
%! syms x
%! assert (isequal (igamma (2, x), gammainc(x, 2, 'upper')))
