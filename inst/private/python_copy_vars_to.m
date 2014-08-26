function s = python_copy_vars_to(in, te, varargin)
%private function

  if (~te)
    %% no error checking
    s = [ sprintf('%s = []\n', in) ...
          do_list(0, in, varargin) ];
  else
    %% put inside try-except
    s1 = sprintf('try:\n    %s = []\n', in);
    L = do_list(4, in, varargin);
    newl = sprintf('\n');
    %newl = '\n';
    s2 = mystrjoin(L, newl);
    s3 = sprintf([ ...
      '    octoutput_drv("PYTHON: successful variable import")\n' ...
      'except:\n' ...
      '    octoutput_drv("PYTHON: Error in variable import")\n' ...
      '    myerr(sys.exc_info())\n' ...
      '    raise\n' ...
      '\n\n']);
    s = [s1 s2 newl s3];
  end
end


function a = do_list(indent, in, varlist)

  sp = repmat(' ', 1, indent);
  a = {}; c = 0;
  for i = 1:numel(varlist)
    x = varlist{i};

    if (isa(x,'sym'))
      c=c+1; a{c} = [sp '# sympy expression'];
      % need to be careful here: pickle might have escape codes
      % .append(pickle.loads("""%s"""))', x.pickle)
      % The extra printf around the pickle helps if it still has
      % escape codes (and seems harmless if it does not)
      c=c+1; a{c} = sprintf('%s%s.append(%s)', sp, in, sprintf(x.pickle));

    elseif (ischar(x))
      c=c+1; a{c} = [sp '# string'];
      c=c+1; a{c} = [sp in '.append("' x '")'];
      % or do we want a printf() around the string?
      %c=c+1; a{c} = sprintf('%s%s.append("%s")', sp, in, x);

    elseif (islogical(x) && isscalar(x))
      c=c+1; a{c} = [sp '# bool'];
      if (x)
        c=c+1; a{c} = [sp in '.append(True)'];
      else
        c=c+1; a{c} = [sp in '.append(True)'];
      end

    elseif (isinteger(x) && isscalar(x))
      c=c+1; a{c} = [sp '# int type'];
      c=c+1; a{c} = sprintf('%s%s.append(%d)', sp, in, x);

    elseif (isfloat(x) && isscalar(x))
      % Floating point input.  By default, all Octave numbers are
      % IEEE double: we pass these using the exact hex
      % representation.  We could detect and treat
      % (double-precision) integers specially (which might
      % help with indexing in some places) but I think it might be
      % too magical.  For now, all doubles become floats in Python.

      %if (mod(x,1) == 0)  % pass integers
      %  s = sprintf('%s%s%s.append(%d)\n', s, sp, in, x);

      if (isa(x,'single'))
        x = double(x);  % don't hate, would happen in Python anyway
      end
      c=c+1; a{c} = [sp '# double'];
      c=c+1; a{c} = sprintf('%s%s.append(hex2d("%s"))', sp, in, num2hex(x));

    elseif (iscell(x))
      c=c+1; a{c} = [sp '# cell array to list'];
      inn = [in 'n'];
      c=c+1; a{c} = sprintf('%s%s = []', sp, inn);
      c=c+1; a{c} = sprintf('%s%s.append(%s)', sp, in, inn);
      b = do_list(indent, inn, x);
      a = {a{:} b{:}};
      c = length(a);

    elseif (isstruct(x) && isscalar(x))
      c=c+1; a{c} = [sp '# struct to dict'];
      inkeys = [in 'k'];
      invalues = [in 'v'];
      c=c+1; a{c} = sprintf('%s%s = []', sp, inkeys);
      b = do_list(indent, inkeys, fieldnames(x));
      a = {a{:} b{:}};
      c = length(a);
      c=c+1; a{c} = sprintf('%s%s = []', sp, invalues);
      b = do_list(indent, indent, invalues, struct2cell(x));
      a = {a{:} b{:}};
      c = length(a);
      c=c+1; a{c} = sprintf('%s%s.append(dict(zip(%s,%s)))', sp, in, inkeys, invalues);

    else
      i, x
      error('don''t know how to move that variable to python');
    end
  end
  c=c+1; a(c) = [sp '# end of a list'];
end


