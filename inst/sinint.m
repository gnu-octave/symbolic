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
%%
%% @strong{WARNING} This implementation is rather poor.
%% @itemize
%% @item It has very large errors for @code{abs(x) > 100}.
%% @item Even for small @var{x}, the relative error is often
%%       as large as @code{500*eps} (accurate to only about
%%       13 decimals).
%% @end itemize
%% If you can, please help improve Octave by contributing to an
%% improved implementation!
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


%!assert (isequal (sinint (0), 0))

%!xtest
%! % FIXME: could relax to within eps
%! assert (isequal (sinint (inf), pi/2))
%! assert (isequal (sinint (-inf), -pi/2))

% FIXME: these should be tighter
%!assert (sinint (1), 0.9460830703671830149414, 10*eps)
%!assert (sinint (-1), -0.9460830703671830149414, 10*eps)
%!assert (sinint (pi), 1.851937051982466170361, 20*eps)
%!assert (sinint (-pi), -1.851937051982466170361, 20*eps)

%!xtest
%! % FIXME: when these pass, split these out into individual asserts
%! assert (sinint (300), 1.570881088213749519252, 2*eps)
%! assert (sinint (1e4), 1.570233121968771218148, 2*eps)
%! assert (sinint (20i), 1.280782633202829445942e8*1i, -5*eps)

%!test
%! % random complex points in disc radius 4
%! a = 0; b = 4; N = 30;
%! t = floor(9*rand(1,N))+1;
%! rs = (b-a) * sym(t)/9 + a;
%! r = (b-a) * t/9 + a;
%! ths = linspace(sym(0), 2*sym(pi), N);
%! th = linspace(0, 2*pi, N);
%! zs = rs.*exp(1i*ths);
%! z = r.*exp(1i*th);
%! A = sinint(z);
%! B = double(sinint(zs));
%! assert (A, B, -20*eps)   % should be tighter

%!test
%! % random real points in [0 100]
%! xs = linspace(0, sym(100), 20);
%! x = linspace(0, 100, 20);
%! A = sinint(x);
%! B = double(sinint(xs));
%! assert (A, B, 500*eps)  % should be tighter

%!xtest
%! % random complex points in annulus [4, 25]
%! a = 5; b = 25; N = 30;
%! t = floor(9*rand(1,N))+1;
%! rs = (b-a) * sym(t)/9 + a;
%! r = (b-a) * t/9 + a;
%! ths = linspace(sym(0), 2*sym(pi), N);
%! th = linspace(0, 2*pi, N);
%! zs = rs.*exp(1i*ths);
%! z = r.*exp(1i*th);
%! A = sinint(z);
%! B = double(sinint(zs));
%! assert (A, B, -20*eps)
