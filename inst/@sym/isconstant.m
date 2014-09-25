%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn {Function File}  {@var{y} =} isconstant (@var{x})
%% Indicate which elements of symbolic array are constant
%%
%% @seealso{symvar, findsymbols}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = isconstant(x)

  % non-elem-wise:
  %z = isempty (findsymbols (x));

  if (isscalar(x))
    z = python_cmd ('return _ins[0].is_constant(),', x);
  else
    z = zeros (size (x), 'logical');
    for i = 1:numel(x)
      % f'ing bug #17, gets me everytime
      %z(i) = isconstant (x(i));
      idx.type = '()'; idx.subs = {i};
      z(i) = isconstant (subsref (x, idx));
    end
  end
  return

  % FIXME this looks useful, but Issue #27: Matrix of bools not converted to logical
  cmd = { '(x,) = _ins'
          'if x.is_Matrix:'
          '    return x.applyfunc(lambda a: a.is_constant()),'
          'else:'
          '    return x.is_constant(),' };
  z = python_cmd (cmd, sym(x));
end





