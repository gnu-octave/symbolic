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
      '    octoutput_drv("PYTHON: Error in variable import")' ...
      '    myerr(sys.exc_info())' ...
      '    raise' };
  end
end


function a = do_list(indent, in, varlist)

  sp = repmat(' ', 1, indent);
  a = {}; c = 0;
  for i = 1:numel(varlist)
    x = varlist{i};

    if (isa(x,'sym'))
      c=c+1; a{c} = [sp '# sym'];
      % need to be careful here: pickle might have escape codes
      % .append(pickle.loads("""%s"""))', x.pickle)
      % The extra printf around the pickle helps if it still has
      % escape codes (and seems harmless if it does not)
      % Issue #107: x.pickle fails for matrices, use char() as workaround
      c=c+1; a{c} = sprintf('%s%s.append(%s)', sp, in, sprintf(char(x)));

    elseif (ischar(x))
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

    elseif (isfloat(x) && isscalar(x))
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

    else
      i, x
      error('don''t know how to move that variable to python');
    end
  end
  c=c+1; a{c} = [sp '# end of a list'];
end


