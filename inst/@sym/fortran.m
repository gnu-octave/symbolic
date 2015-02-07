%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{s} =} fortran (@var{g})
%% @deftypefnx {Function File} {@var{s} =} fortran (@var{g1}, @dots{}, @var{gn})
%% @deftypefnx {Function File} {} fortran (@dots{}, 'file', @var{filename})
%% @deftypefnx {Function File} {[@var{F}, @var{H}] =} fortran (@dots{}, 'file', '')
%% Convert symbolic expression into C code.
%%
%% FIXME: make sure this works
%% @example
%% syms x
%% g = taylor(log(1+x),x,0,6)  % a polynomial
%% g = horner(g)   % optimize w/ Horner's nested evaluation
%% fortran(g)
%% @end example
%%
%% We can write to a file or obtain the contents directly:
%% @example
%% [f90, h] = fortran(f, 'file', '')
%% f90.name   % .f90 filename
%% f90.code   % .f90 file contents
%% h.name     % similarly for .h file
%% h.code
%% @end example
%%
%% FIXME: This doesn't write "optimized" code like Matlab's
%% Symbolic Math Toolbox; it doesn't do "Common Subexpression
%% Elimination".  Presumably the compiler would do that for us
%% anyway.  Sympy has a "cse" module that will do it.  See:
%% http://stackoverflow.com/questions/22665990/optimize-code-generated-by-sympy
%%
%% @seealso{ccode, latex, matlabFunction}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function varargout = fortran(varargin)

  [flg, meh] = codegen(varargin{:}, 'lang', 'F95');

  if flg == 0
    varargout = {};
  elseif flg == 1
    varargout = meh(1);
  elseif flg == 2
    varargout = {meh{1}, meh{2}};
  else
    error('whut?');
  end
end


%!shared x,y,z
%! syms x y z

%!test
%! % basic test
%! f = x*sin(y) + abs(z);
%! source = fortran(f);
%! expected = '      x*sin(y) + Abs(z)';
%! assert(strcmp(source, expected))

%!test
%! % output test
%! f = x*sin(y) + abs(z);
%! [F,H] = fortran(f, 'file', '', 'show_header', false);
%! expected_h_code = sprintf('\ninterface\nREAL*8 function myfun(x, y, z)\nimplicit none\nREAL*8, intent(in) :: x\nREAL*8, intent(in) :: y\nREAL*8, intent(in) :: z\nend function\nend interface\n\n');
%! expected_f_code = sprintf('\nREAL*8 function myfun(x, y, z)\nimplicit none\nREAL*8, intent(in) :: x\nREAL*8, intent(in) :: y\nREAL*8, intent(in) :: z\n\nmyfun = x*sin(y) + Abs(z)\n\nend function\n');
%! assert(strcmp(F.name, 'file.f90'))
%! assert(strcmp(H.name, 'file.h'))
%! %disp(expected_f_code); disp(F.code)
%! s1 = strrep(expected_f_code, sprintf('\n'), sprintf('\r\n'));
%! s2 = strrep(expected_h_code, sprintf('\n'), sprintf('\r\n'));
%! assert (strcmp (F.code, expected_f_code) || strcmp (F.code, s1))
%! assert (strcmp (H.code, expected_h_code) || strcmp (H.code, s2))
