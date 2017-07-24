%% Copyright (C) 2014-2015 Colin B. Macdonald
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

function L = python_copy_vars_to(in, te, varargin)
%private function

  if (~te)
    %% no error checking
    L = do_list(0, in, varargin);
    L = { sprintf('%s = []', in) ...
          L{:} };
  else
    %% put inside try-except
    L = do_list(4, in, varargin);
    L = { 'try:' ...
          sprintf('    %s = []', in) ...
          L{:} ...
          '    octoutput_drv("PYTHON: successful variable import")' ...
          'except:' ...
          '    echo_exception_stdout("while copying variables to Python")' ...
          '    raise'
        };
  end
end


function a = do_list(indent, in, varlist)

  sp = repmat(' ', 1, indent);
  a = {}; c = 0;
  for i = 1:numel(varlist)
    x = varlist{i};

    if (isa(x,'sym'))
      c=c+1; a{c} = [sp '# sym'];
      % The extra printf around the srepr helps if it still has
      % escape codes (and seems harmless if it does not)
      c=c+1; a{c} = sprintf ('%s%s.append(%s)', sp, in, sprintf (sympy (x)));

    elseif (ischar(x))
      assert (strcmp (x, '') || isrow (x), ...
	      'multirow char arrays cannot be converted to Python strings')
      if (exist ('OCTAVE_VERSION', 'builtin'))
        x = undo_string_escapes(x);
      else
        % roughly same as the above on Matlab?
        x = strrep(x, '\', '\\');
        x = strrep(x, '"', '\"');
        for cc = {'\n' '\r' '\t' '\b' '\f'}
          x = strrep(x, sprintf(cc{:}), cc{:});
        end
      end
      c=c+1; a{c} = [sp in '.append("' x '")'];
      % or do we want a printf() around the string?
      %c=c+1; a{c} = sprintf('%s%s.append("%s")', sp, in, x);

    elseif (islogical(x) && isscalar(x))
      if (x)
        c=c+1; a{c} = [sp in '.append(True)'];
      else
        c=c+1; a{c} = [sp in '.append(False)'];
      end

    elseif (isinteger(x) && isscalar(x))
      c=c+1; a{c} = sprintf('%s%s.append(%s)  # int type', ...
                            sp, in, num2str(x, '%ld'));

    elseif (isfloat(x) && isscalar(x) && isreal(x))
      % Floating point input.  By default, all Octave numbers are
      % IEEE double: we pass these using the exact hex
      % representation.  We could detect and treat
      % (double-precision) integers specially (which might
      % help with indexing in some places) but I think it might be
      % too magical.  For now, all doubles become floats in Python.

      if (isa(x, 'single'))
        x = double(x);  % don't hate, would happen in Python anyway
      end
      c=c+1; a{c} = sprintf('%s%s.append(hex2d("%s"))  # double', ...
                            sp, in, num2hex(x));

    elseif (isfloat(x) && isscalar(x))  % iscomplex(x)
      if (isa(x, 'single'))
        x = double(x);  % don't hate, would happen in Python anyway
      end
      c=c+1; a{c} = sprintf('%s%s.append(hex2d("%s")+hex2d("%s")*1j)  # complex', ...
                            sp, in, num2hex(real(x)), num2hex(imag(x)));

    elseif (iscell(x))
      c=c+1; a{c} = [sp '# cell array: xfer to list'];
      inn = [in 'n'];
      c=c+1; a{c} = sprintf('%s%s = []', sp, inn);
      c=c+1; a{c} = sprintf('%s%s.append(%s)', sp, in, inn);
      b = do_list(indent, inn, x);
      a = {a{:} b{:}};
      c = length(a);

    elseif (isstruct(x) && isscalar(x))
      c=c+1; a{c} = [sp '# struct: xfer to dict'];
      inkeys = [in 'k'];
      invalues = [in 'v'];
      c=c+1; a{c} = sprintf('%s%s = []', sp, inkeys);
      b = do_list(indent, inkeys, fieldnames(x));
      a = {a{:} b{:}};
      c = length(a);
      c=c+1; a{c} = sprintf('%s%s = []', sp, invalues);
      b = do_list(indent, invalues, struct2cell(x));
      a = {a{:} b{:}};
      c = length(a);
      c=c+1; a{c} = sprintf('%s%s.append(dict(zip(%s,%s)))', sp, in, inkeys, invalues);

    elseif (ismatrix(x) && (isnumeric(x) || islogical(x)))
      % What should we do with double arrays?  Perhaps map them to numpy
      % arrays is the most useful in general.  For now, we map them to a
      % list-of-lists.  This could change in the future.  See also:
      % https://github.com/cbm755/octsympy/issues/134
      % https://github.com/cbm755/octsympy/pull/336
      c=c+1; a{c} = sprintf('%s%s.append(%s)', sp, in, sprintf(octave_array_to_python(x)));

    else
      i, x
      error('don''t know how to move that variable to python');
    end
  end
  c=c+1; a{c} = [sp '# end of a list'];
end


