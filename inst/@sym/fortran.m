%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
%% Copyright (C) 2017 Mike Miller
%% Copyright (C) 2017 Alex Vong
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
%% @deftypemethod  @@sym {@var{s} =} fortran (@var{g})
%% @deftypemethodx @@sym {@var{s} =} fortran (@var{g1}, @dots{}, @var{gn})
%% @deftypemethodx @@sym {} fortran (@dots{}, 'file', @var{filename})
%% @deftypemethodx @@sym {[@var{F}, @var{H}] =} fortran (@dots{}, 'file', '')
%% Convert symbolic expression into Fortran code.
%%
%% Example returning a string of Fortran code:
%% @example
%% @group
%% syms x
%% g = taylor(log(1 + x), x, 0, 'order', 5);
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% g = horner(g)
%%   @result{} g = (sym)
%%         ⎛  ⎛  ⎛1   x⎞   1⎞    ⎞
%%       x⋅⎜x⋅⎜x⋅⎜─ - ─⎟ - ─⎟ + 1⎟
%%         ⎝  ⎝  ⎝3   4⎠   2⎠    ⎠
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% fortran(g)
%%   @result{} x*(x*(x*(1.0d0/3.0d0 - 1.0d0/4.0d0*x) - 1.0d0/2.0d0) + 1)
%% @end group
%% @end example
%%
%% We can write to a file or obtain the contents directly:
%% @example
%% @group
%% [f90, h] = fortran(g, 'file', '', 'show_header', false);
%% f90.name
%%   @result{} file.f90
%% h.name
%%   @result{} file.h
%% @end group
%%
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% disp(f90.code)
%%   @print{}  REAL*8 function myfun(x)
%%   @print{}  implicit none
%%   @print{}  REAL*8, intent(in) :: x
%%   @print{}
%%   @print{}  myfun = x*(x*(x*(1.0d0/3.0d0 - 1.0d0/4.0d0*x) - 1.0d0/2.0d0) + 1)
%%   @print{}
%%   @print{}  end function
%% @end group
%%
%% @group
%% disp(h.code)
%%   @print{}  interface
%%   @print{}  REAL*8 function myfun(x)
%%   @print{}  implicit none
%%   @print{}  REAL*8, intent(in) :: x
%%   @print{}  end function
%%   @print{}  end interface
%% @end group
%% @end example
%%
%% FIXME: This doesn't write ``optimized'' code like Matlab's
%% Symbolic Math Toolbox; it doesn't do ``Common Subexpression
%% Elimination''.  Presumably the compiler would do that for us
%% anyway.  Sympy has a ``cse'' module that will do it.  See:
%% http://stackoverflow.com/questions/22665990/optimize-code-generated-by-sympy
%%
%% @seealso{@@sym/ccode, @@sym/latex, @@sym/function_handle}
%% @end deftypemethod


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
%! expected = '      x*sin(y) + abs(z)';
%! s1 = strrep (expected, 'abs', 'Abs');
%! assert (strcmp (source, expected) || strcmp (source, s1))

%!test
%! % output test
%! f = x*sin(y) + abs(z);
%! [F,H] = fortran(f, 'file', '', 'show_header', false);
%! expected_h_code = sprintf('\ninterface\nREAL*8 function myfun(x, y, z)\nimplicit none\nREAL*8, intent(in) :: x\nREAL*8, intent(in) :: y\nREAL*8, intent(in) :: z\nend function\nend interface\n\n');
%! expected_f_code = sprintf('\nREAL*8 function myfun(x, y, z)\nimplicit none\nREAL*8, intent(in) :: x\nREAL*8, intent(in) :: y\nREAL*8, intent(in) :: z\n\nmyfun = x*sin(y) + abs(z)\n\nend function\n');
%! assert(strcmp(F.name, 'file.f90'))
%! assert(strcmp(H.name, 'file.h'))
%! %disp(expected_f_code); disp(F.code)
%! s1 = strrep (expected_f_code, 'abs', 'Abs');
%! s2 = strrep (expected_f_code, sprintf ('\n'), sprintf ('\r\n'));
%! s3 = strrep (s2, 'abs', 'Abs');
%! s4 = strrep (expected_h_code, sprintf ('\n'), sprintf ('\r\n'));
%! assert (strcmp (F.code, expected_f_code) || strcmp (F.code, s1) || strcmp (F.code, s2) || strcmp (F.code, s3))
%! assert (strcmp (H.code, expected_h_code) || strcmp (H.code, s4))
