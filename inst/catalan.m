%% Copyright (C) 2015 Carnë Draug
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
%% @deftypefn {Function File} {} catalan ()
%% Return Catalan constant.
%%
%% @example
%% vpa (catalan ())
%% @result{} (sym) 0.91596559417721901505460351493238
%% @end example
%%
%% @seealso{eulergamma}
%% @end deftypefn

%% Author: Carnë Draug
%% Keywords: symbolic, constants

function g = catalan ()
  g = python_cmd ('return sympy.S.Catalan,');
end

%!assert (double (catalan ()) > 0.915965594177)
%!assert (double (catalan ()) < 0.915965594178)
