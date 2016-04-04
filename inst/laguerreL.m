%% Copyright (C) 2008 Eric Chassande-Mottin
%% Copyright (C) 2011 Carnë Draug
%% Copyright (C) 2016 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{y} = } laguerreL (@var{n}, @var{x})
%% @deftypefnx {Function File} {[@var{y}, @var{p}] = } laguerreL (@var{n}, @var{x})
%%
%% Compute the value of the Laguerre polynomial of order @var{n}
%% for each element of @var{x}.
%%
%% @end deftypefn

function [y, p] = laguerreL(n, x)

  if (nargin ~= 2)
    print_usage ();
  elseif (n < 0 || ~isscalar (n) || (mod(n, 1) ~= 0))
    error('second argument "n" must be a positive integer');
  end

  p0=1;
  p1=[-1 1];

  if (n==0)
    p=p0;
  elseif (n==1)
    p=p1;
  elseif (n > 1)
    % recursive calculation of the polynomial coefficients
    for k=2:n
      p=zeros(1,k+1);
      p(1) = -p1(1)/k;
      p(2) = ((2*k-1)*p1(1)-p1(2))/k;
      if (k > 2)
        p(3:k) = ((2*k-1)*p1(2:k-1)-p1(3:k)-(k-1)*p0(1:k-2))/k;
      end
      p(k+1) = ((2*k-1)*p1(k)-(k-1)*p0(k-1))/k;
      p0=p1;
      p1=p;
    end
  end

  y=polyval(p,x);

end

%!test
%! x=rand;
%! y1=laguerreL(0, x);
%! p0=[1]; 
%! y2=polyval(p0,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerreL(1, x);
%! p1=[-1 1]; 
%! y2=polyval(p1,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerreL(2, x);
%! p2=[.5 -2 1];
%! y2=polyval(p2,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerreL(3, x);
%! p3=[-1/6 9/6 -18/6 1];
%! y2=polyval(p3,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerreL(4, x);
%! p4=[1/24 -16/24 72/24 -96/24 1];
%! y2=polyval(p4,x);
%! assert(y1-y2,0,eps);

%!error <positive integer> laguerreL(1.5, 10)
%!error <Invalid call> laguerreL(10)
