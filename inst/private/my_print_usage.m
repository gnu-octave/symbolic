%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {} print_usage ()
%% Wrapper for print_usage on Matlab.
%%
%% Matlab has no print_usage function.  Preparing
%% the Matlab package should rename this from
%% "my_print_usage.m" to "print_usage.m".
%%
%% @seealso{error}
%% @end deftypefn

function print_usage ()

  % if we are on Octave
  if (exist ('OCTAVE_VERSION', 'builtin'))
    %evalin ('caller', 'print_usage ();' );
    %return
  end

  H = dbstack;
  name = H(2).name;

  msgid = sprintf('%s:invalidCall', name);
  errmsg = sprintf('Invalid call to "%s": see documentation', name);

  %error('Invalid call to "%s": see documentation', name)
  ME = MException(msgid, errmsg);
  ME.throwAsCaller();

end
