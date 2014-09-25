%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of Octave-Symbolic-SymPy
%%
%% Octave-Symbolic-SymPy is free software; you can redistribute
%% it and/or modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 3 of the License, or (at your option) any
%% later version.
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
%% @deftypefn  {Function File} {@var{c} =} coeffs (@var{p}, @var{x})
%% Return coefficients of symbolic polynomial @var{p}
%%
%% FIXME; DOC this is just sym2poly copied.
%%
%% If there is only one free variable in @var{p} the
%% coefficient vector @var{c} is a plain numeric vector (double).  If there is more
%% than one free variable in @var{p}, a second argument @var{x} specifies the
%% free variable and the function returns a row vector of symbolic expressions.
%% The coefficients correspond to decreasing exponent of the free variable.
%%
%% Example:
%% @example
%% x = sym ('x');
%% y = sym ('y');
%% c = sym2poly (x^2 + 3*x - 4);    % c = [1 3 -4]
%% c = sym2poly (x^2 + y*x, x);     % c = [sym(1) y sym(0)]
%% @end example
%%
%% If @var{p} is not a polynomial the result has no warranty.  SymPy can
%% certainly deal with more general concepts of polynomial but we do not
%% yet expose all of that here.
%%
%% @seealso{poly2sym,polyval,roots}
%% @end deftypefn

function c = coeffs(p,x)

  warning('FIXME')

  if ~(isscalar(p))
    error('works for scalar input only');
  end

  if (nargin == 1)
    ss = findsymbols(p);
    if (length(ss) > 2)
      error('Input has more than one symbol: not clear what you want me to do')
    end
    x = ss{1};
    convert_to_double = true;
  else
    convert_to_double = false;
  end

  cmd = { 'f = _ins[0]'
          'x = _ins[1]'
          'p = Poly.from_expr(f, x)'
          'c = p.all_coeffs()'
          'return c,' };

  c2 = python_cmd (cmd, p, x);
  if (isempty(c2))
    error('Empty python output, can this happen?  A bug.')
  end

  % FIXME: should be able to convert c2 to array faster than array
  % expansion!  Particularly in the case where we just convert to
  % double anyway!
  c = sym([]);
  for j = 1:numel(c2)
    % Bug #17
    %c(j) = c2{j};
    idx.type = '()'; idx.subs = {j};
    c = subsasgn(c, idx, c2{j});
  end

  if (convert_to_double)
    c = double(c);
  end

end
