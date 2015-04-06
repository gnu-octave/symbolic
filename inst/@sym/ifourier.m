%% Copyright (C) 2015 Colin B. Macdonald, Alexander Misel
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
%% @deftypefn  {Function File} {@var{f} =} ifourier (@var{FF}, @var{w}, @var{x})
%% @deftypefnx {Function File} {@var{f} =} ifourier (@var{FF})
%% @deftypefnx {Function File} {@var{f} =} ifourier (@var{FF}, @var{x})
%% Symbolic inverse Fourier transform.
%%
%% FIXME: doc
%%
%% Examples:
%% @example
%% syms x w
%% F = 1/(1+w^2)
%% ifourier(F)
%% ifourier(F, w)
%% ifourier(F, x, w)
%% @end example
%%
%% @seealso{fourier,laplace}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function f = ifourier(varargin)

  syms F w x;
  if (nargin == 1)
    F=varargin{1};
    w=symvar(F,1);

  elseif (nargin == 2)
    F=varargin{1};
    w=symvar(F,1);
    x=varargin{2};

  elseif (nargin == 3)
    F=varargin{1};
    w=varargin{2}; 
    x=varargin{3};

  else
    error('Wrong number of input arguments') 
 
  endif

  cmd = { 'sp.InverseFourierTransform._a = 0.5/S.Pi'
          'sp.InverseFourierTransform._b = 1'
          'F = sp.inverse_fourier_transform(*_ins)'
          'return F,'};
  f = python_cmd(cmd,F,w,x);

end


%!test
%! syms x k
%! f = exp(-x^2);
%! F = fourier(f,x,k);
%! g = ifourier(F,k,x);
%! assert(isequal(f,g))
