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
%% @deftypefn {Function File} {@var{r} =} octsympy_reset ()
%% Reset the SymPy communication mechanism.
%%
%% Returns true if called with an output and reset was successful.
%%
%% @seealso{syms, octsympy_config}
%% @end deftypefn

function varargout = octsympy_reset()

  disp('Resetting the octsympy communication mechanism');
  r = python_sympy_cmd_raw('reset', []);

  if (nargout == 0)
    if (~r)
      disp('Problem resetting');
    end
  else
    varargout{1} = r;
  end

end


%!test
%! syms x
%! r = octsympy_reset();
%! assert(r)
