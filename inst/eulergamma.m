%% Copyright (C) 2015 Carnë Draug
%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
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
%% @deffn Constant eulergamma ()
%% Return Euler--Mascheroni constant.
%%
%% @example
%% @group
%% eulergamma
%%   @result{} (sym) γ
%%
%% vpa (eulergamma ())
%%   @result{} (sym) 0.57721566490153286060651209008240
%% @end group
%% @end example
%%
%% @seealso{catalan}
%% @end deffn

%% Author: Carnë Draug
%% Keywords: symbolic, constants

function g = eulergamma ()

  if (nargin ~= 0)
    print_usage ();
  end

  g = pycall_sympy__ ('return sympy.S.EulerGamma,');
end


%!error <Invalid> catalan (sym(1))
%!assert (double (eulergamma ()) > 0.577215664901)
%!assert (double (eulergamma ()) < 0.577215664902)
