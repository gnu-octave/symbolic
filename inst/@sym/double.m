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
%% @deftypefn  {Function File} {@var{y} =} double (@var{x})
%% @deftypefnx {Function File} {@var{y} =} double (@var{x}, false)
%% Convert symbolic to doubles.
%%
%% Example:
%% @example
%% x = sym(1) / 3
%% double (x)
%% @end example
%%
%% If conversion fails, you get an error:
%% @example
%% syms x
%% double (x)
%% @end example
%%
%% You can pass an optional second argument of @code{false} to
%% return an empty array if conversion fails on any component.
%%
%% Example:
%% @example
%% syms x
%% a = [1 2 x];
%% b = double (a, false)
%% isempty (b)
%% @end example
%%
%% @seealso{sym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = double(x, failerr)

  if (nargin == 1)
    failerr = true;
  end

  if ~(isscalar(x))
    % sympy N() works fine on matrices but it gives objects like "Matrix([[1.0,2.0]])"
    y = zeros(size(x));
    for j = 1:numel(x)
      % Bug #17
      idx.type = '()';
      idx.subs = {j};
      temp = double(subsref(x,idx), failerr);
      if (isempty(temp))
        y = [];
        return
      end
      y(j) = temp;
    end
    return
  end

  % FIXME: maybe its better to do the special casing, etc on the
  % python end?  Revisit this when fixing proper movement of
  % doubles (Bug #11).

  cmd = [ '(x,) = _ins\n'  ...
          'y = sp.N(x,20)\n'  ...
          'y = str(y)\n'  ...
          'return (y,)' ];

  A = python_cmd (cmd, x);
  assert(ischar(A))

  % workaround for Octave 3.6.4 where str2double borks on "inf"
  % instead of "Inf".
  % http://hg.savannah.gnu.org/hgweb/octave/rev/a08f6e17336e
  %if (is_octave())
  if exist('octave_config_info', 'builtin');
    if (compare_versions (OCTAVE_VERSION (), '3.8.0', '<'))
      A = strrep(A, 'inf', 'Inf');
    end
  end

  % special case for nan so we can later detect if str2double finds a double
  if (strcmp(A, 'nan'))
    y = NaN;
    return
  end

  % special case for zoo, at least in sympy 0.7.4, 0.7.5
  if (strcmp(A, 'zoo'))
    y = Inf;
    return
  end

  y = str2double (A);
  if (isnan (y))
    y = [];
    if (failerr)
      error('Failed to convert %s ''%s'' to double', class(x), x.text);
    end
  end
end


%!assert (double (sym(10) == 10))
%!assert (double (sym([10 12]) == [10 12]))
%!test
%! assert (isempty (double (sym('x'), false)))
%! assert (isempty (double (sym([10 12 sym('x')]), false)))
