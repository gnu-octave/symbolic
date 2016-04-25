%% Copyright (C) 2006 Sylvain Pelissier <sylvain.pelissier@gmail.com>
%%
%% This program is free software; you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation; either version 3 of the License, or (at your option) any later
%% version.
%%
%% This program is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public License along with
%% this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defun sinint (@var{x})
%% Compute the sine integral function.
%%
%% The sine integral function is defined for complex inputs @var{x} by:
%% @verbatim
%%                    x
%%                   /
%%       sinint(x) = | sin(t)/t dt
%%                   /
%%                   0
%% @end verbatim
%%
%% Example:
%% @example
%% @group
%% sinint (1)
%%   @result{} 0.94608
%% @end group
%% @end example
%% @seealso{cosint, expint, @@sym/sinint}
%% @end defun

function y = sinint (x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = zeros(size(x));
  if prod(size(x)) < 101
    for k = 1:prod(size(x))
      y(k) = sum(besselj([0:100]+0.5,(x(k)/2)).^2);
    end
    y = y.*pi;
  else
    for k=0:100
      y = y + besselj(k+0.5,x/2).^2;
    end
    y = y.*pi;
  end
end
