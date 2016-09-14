%% Copyright (C) 2016 Lagu and Mike Miller
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
%% @deffn Command isassumption @var{x}
%% Return the indices of non existent assumptions.
%%
%% @example
%% @group
%% isassumption(@{"real", "prime", "polar"@})
%%   @result{} ...
%% @end group
%% @end example
%%
%% To break if you found a non existent assumption:
%% @example
%% @group
%%   names = @{"real", "positive", "prime", "foo", "bar"@};
%%   idx = isassumption (names);
%%   if (any (idx))
%%     error ("MyFunc: These assumptions are not supported: %s", strjoin (names(idx), ", "));
%%   endif
%%   @result{} ...
%% @end group
%% @end example
%%
%% @seealso{sym, syms, assumptions, @@sym/assume, @@sym/assumeAlso}
%% @end deffn


function out = isassumption(in)

  list = assumptions('possible');
  out = [];  

  for i=1:length(in)
    if (isempty(strmatch(in{i}, list, 'exact')))
      out = [out, i];
    end
  end
  
end


%!test
%! out = isassumption({"blabla", "mehmeh"});
%! assert( isequal( out, [1, 2]))
