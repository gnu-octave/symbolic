%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2016 Colin B. Macdonald
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
%% @deftypefun @var{s} = create_sym_with_s (@var{x})
%% Create sym from string @var{x} using the function 'S' of sympy.
%%
%% Private helper function.
%%
%% @seealso{sym}
%% @end deftypefun


function s = create_sym_with_s(x)
  cmd = {'x = "{s}"'
         'try:'
         '    return (0, (0, 0), S(x, rational=True))'
         'except Exception as e:'
         '    lis = set()'
         '    if "(" in x or ")" in x:'
         '        x2 = split("\(|\)| |,", x)'
         '        x2 = [p for p in x2 if p]'
         '        for i in x2:'
         '            try:'
         '                if eval("callable(" + i + ")"):'
         '                    lis.add(i)'
         '            except:'
         '                pass'
         '    if len(lis) > 0:'
         '        return (str(e), (1, "" if len(lis) == 1 else "s"), "\", \"".join(str(e) for e in lis))'
         '    return (str(e), (2, 0), x)' };

  [err flag s] = python_cmd (strrep (cmd, '{s}', x));
  switch (flag{1})
    case 1  % Bad call to python function
      disp (['Python: ' err]);
      disp (['error: Error using the "' s '" Python function' flag{2} ', you wrote it correctly?']);
      error ('if this do not was intentional please use other var name.');
    case 2  % Something else
      disp (['Python: ' err]);
      error (['You can not use var name "' s '" for a error, if is a bug please report it.']);
  end
end
