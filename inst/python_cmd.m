%% Copyright (C) 2014-2019 Colin B. Macdonald
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
%% @deftypefun {[@var{a}, @var{b}, @dots{}] =} python_cmd (@var{cmd}, @var{x}, @var{y}, @dots{})
%% Run some Python command on some objects and return other objects.
%%
%% DEPRECATION: This function is deprecated and will be removed in
%% a future release.
%%
%% This function was never really intended for end users.
%%
%% @seealso{pycall_sympy__}
%% @end deftypefun


function varargout = python_cmd(cmd, varargin)

  warning('OctSymPy:deprecated', 'python_cmd: deprecated, use `pycall_sympy__` instead')

  [varargout{1:nargout}] = pycall_sympy__ (cmd, varargin);
end


%!test
%! s = warning ('off', 'OctSymPy:deprecated');
%! a = python_cmd ('return 42');
%! assert (a == 42)
%! warning (s)
