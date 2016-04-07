## Copyright (C) 1998 by Nicol N. Schraudolph <schraudo@inf.ethz.ch>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x} = } lambertw (@var{z})
## @deftypefnx {Function File} {@var{x} = } lambertw (@var{n}, @var{z})
## Compute the Lambert W function of @var{z}.
##
## This function satisfies W(z).*exp(W(z)) = z, and can thus be used to express
## solutions of transcendental equations involving exponentials or logarithms.
##
## @var{n} must be integer, and specifies the branch of W to be computed;
## W(z) is a shorthand for W(0,z), the principal branch.  Branches
## 0 and -1 are the only ones that can take on non-complex values.
##
## If either @var{n} or @var{z} are non-scalar, the function is mapped to each
## element; both may be non-scalar provided their dimensions agree.
##
## This implementation should return values within 2.5*eps of its
## counterpart in Maple V, release 3 or later.  Please report any
## discrepancies to the author, Nici Schraudolph <schraudo@@inf.ethz.ch>.
##
## For further details, see:
##
## Corless, Gonnet, Hare, Jeffrey, and Knuth (1996), `On the Lambert
## W Function', Advances in Computational Mathematics 5(4):329-359.
## @end deftypefn

function w = lambertw(b,z)
    if (nargin == 1)
        z = b;
        b = 0;
    else
        %% some error checking
        if (nargin != 2)
            print_usage;
        else
            if (any(round(real(b)) != b))
                usage('branch number for lambertw must be integer')
            end
        end
    end

    %% series expansion about -1/e
    %
    % p = (1 - 2*abs(b)).*sqrt(2*e*z + 2);
    % w = (11/72)*p;
    % w = (w - 1/3).*p;
    % w = (w + 1).*p - 1
    %
    % first-order version suffices:
    %
    w = (1 - 2*abs(b)).*sqrt(2*e*z + 2) - 1;

    %% asymptotic expansion at 0 and Inf
    %
    v = log(z + ~(z | b)) + 2*pi*I*b;
    v = v - log(v + ~v);

    %% choose strategy for initial guess
    %
    c = abs(z + 1/e);
    c = (c > 1.45 - 1.1*abs(b));
    c = c | (b.*imag(z) > 0) | (~imag(z) & (b == 1));
    w = (1 - c).*w + c.*v;

    %% Halley iteration
    %
    for n = 1:10
        p = exp(w);
        t = w.*p - z;
        f = (w != -1);
        t = f.*t./(p.*(w + f) - 0.5*(w + 2.0).*t./(w + f));
        w = w - t;
        if (abs(real(t)) < (2.48*eps)*(1.0 + abs(real(w)))
            && abs(imag(t)) < (2.48*eps)*(1.0 + abs(imag(w))))
            return
        end
    end
    warning('iteration limit reached, result of lambertw may be inaccurate');
end

