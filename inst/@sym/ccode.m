%% Copyright (C) 2014-2016, 2018-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{s} =} ccode (@var{f})
%% @deftypemethodx @@sym {@var{s} =} ccode (@var{f1}, @dots{}, @var{fn})
%% @deftypemethodx @@sym {} ccode (@dots{}, 'file', @var{filename})
%% @deftypemethodx @@sym {[@var{c_stuff}, @var{h_stuff}] =} ccode (@dots{}, 'file', '')
%% Convert symbolic expression into C code.
%%
%% Example:
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
%% ccode(g)
%%   @result{} x*(x*(x*(1.0/3.0 - 1.0/4.0*x) - 1.0/2.0) + 1)
%% @end group
%% @end example
%%
%% We can write to a file or obtain the contents directly:
%% @example
%% @group
%% [C, H] = ccode(g, 'file', '', 'show_header', false);
%% C.name
%%   @result{} file.c
%% H.name
%%   @result{} file.h
%% @end group
%%
%% @group
%% disp(H.code)
%%   @print{}  #ifndef PROJECT__FILE__H
%%   @print{}  #define PROJECT__FILE__H
%%   @print{}
%%   @print{}  double myfun(double x);
%%   @print{}
%%   @print{}  #endif
%% @end group
%%
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% disp(C.code)
%%   @print{}  #include "file.h"
%%   @print{}  #include <math.h>
%%   @print{}
%%   @print{}  double myfun(double x) @{
%%   @print{}
%%   @print{}     double myfun_result;
%%   @print{}     myfun_result = x*(x*(x*(1.0/3.0 - 1.0/4.0*x) - 1.0/2.0) + 1);
%%   @print{}     return myfun_result;
%%   @print{}
%%   @print{}  @}
%% @end group
%% @end example
%%
%% FIXME: This doesn't write ``optimized'' code like Matlab's
%% Symbolic Math Toolbox; it doesn't do ``Common Subexpression
%% Elimination''.  Presumably the compiler would do that for us
%% anyway.  Sympy has a ``cse'' module that will do it.  See:
%% http://stackoverflow.com/questions/22665990/optimize-code-generated-by-sympy
%%
%% @seealso{@@sym/fortran, @@sym/latex, @@ssym/function_handle}
%% @end deftypemethod


function varargout = ccode(varargin)

  [flg, meh] = codegen(varargin{:}, 'lang', 'C');

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
%! source = ccode(f);
%! expected = 'x*sin(y) + fabs(z)';
%! assert(strcmp(source, expected))

%!test
%! % output test
%! f = x*sin(y) + abs(z);
%! [C, H] = ccode(f, 'file', '', 'show_header', false);
%! expected_c_code = sprintf('#include \"file.h\"\n#include <math.h>\n\ndouble myfun(double x, double y, double z) {\n\n   double myfun_result;\n   myfun_result = x*sin(y) + fabs(z);\n   return myfun_result;\n\n}\n');
%! expected_h_code = sprintf('\n#ifndef PROJECT__FILE__H\n#define PROJECT__FILE__H\n\ndouble myfun(double x, double y, double z);\n\n#endif\n\n');
%! assert(strcmp(C.name, 'file.c'))
%! assert(strcmp(H.name, 'file.h'))
%! hwin = strrep(expected_h_code, sprintf('\n'), sprintf('\r\n'));
%! assert (strcmp (H.code, expected_h_code) || strcmp (H.code, hwin))
%! s1 = expected_c_code;
%! s2 = strrep(expected_c_code, sprintf('\n'), sprintf('\r\n'));
%! assert (strcmp (C.code, s1) || strcmp (C.code, s2))
