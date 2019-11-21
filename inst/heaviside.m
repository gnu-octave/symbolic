%% Copyright (C) 2006 Sylvain Pelissier <sylvain.pelissier@gmail.com>
%% Copyright (C) 2015-2016 Colin B. Macdonald <cbm@m.fsf.org>
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
%% @defun  heaviside (@var{x})
%% @defunx heaviside (@var{x}, @var{zero_value})
%% Compute the Heaviside unit-step function.
%%
%% The Heaviside function is 0 for negative @var{x} and 1 for
%% positive @var{x}.
%%
%% Example:
%% @example
%% @group
%% heaviside([-inf -3 -1 1 3 inf])
%%   @result{} 0     0     0     1     1     1
%% @end group
%% @end example
%%
%% There are various conventions for @code{heaviside(0)}; this
%% function returns 0.5 by default:
%% @example
%% @group
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% heaviside(0)
%%   @result{} 0.5000
%% @end group
%% @end example
%% However, this can be changed via the optional second input
%% argument:
%% @example
%% @group
%% heaviside(0, 1)
%%   @result{} 1
%% @end group
%% @end example
%% @seealso{dirac, @@sym/heaviside}
%% @end defun

function y = heaviside (x, zero_value)
  if (nargin < 1 || nargin > 2)
    print_usage ();
  end
  if (nargin == 1)
    zero_value = 0.5;
  end

  if (~isreal (x))
    error ('heaviside: X must not contain complex values');
  end

  y = cast (x > 0, class (x));
  y(x == 0) = zero_value;

  y(isnan (x)) = NaN;
end


%!assert (heaviside (0) == 0.5)
%!assert (isnan (heaviside (nan)))
%!assert (isequal (heaviside ([-inf -eps 0 eps inf]), [0 0 0.5 1 1]))
%!assert (isequaln (heaviside ([-1 1 nan]), [0 1 nan]))
%!assert (heaviside (0, 1) == 1)
%!error <complex values> heaviside (1i)
%!assert (isa (heaviside (single (0)), 'single'))
