function s = python_copy_vars_to(in, varargin)

  s = '';

  if 1==0
  s = sprintf('%s%s = []\n\n', s, in);
  s = do_list(s, 0, in, varargin);
  else
  tag = ipc_misc_params();

  s = sprintf('%stry:\n', s);
  s = sprintf('%s    %s = []\n', s, in);
  s = do_list(s, 4, in, varargin);
  s = sprintf('%s    print "%s"\n', s, tag.block);
  s = sprintf('%s    print "%s\\n%s"\n', s, tag.item, tag.enditem);
  s = sprintf('%s    print "%s"\n', s, tag.item);
  s = sprintf('%s    print "PYTHON: successful variable import"\n', s);
  s = sprintf('%s    print "%s"\n', s, tag.enditem);
  s = sprintf('%s    print "%s"\n', s, tag.endblock);

  s = sprintf('%sexcept:\n', s);
  s = sprintf('%s    print\n', s);
  s = sprintf('%s    print "%s"\n', s, tag.block);
  s = sprintf('%s    print "%s\\n%s"\n', s, tag.item, tag.enditem);
  s = sprintf('%s    print "%s"\n', s, tag.item);
  s = sprintf('%s    print "PYTHON: Error in variable import"\n', s);
  s = sprintf('%s    print "%s"\n', s, tag.enditem);
  s = sprintf('%s    print "%s"\n', s, tag.endblock);
  s = sprintf('%s\n\n', s);
  %s = sprintf('%s    rethrow\n\n', s, tag.endblock);
  end
end


function s = do_list(s, indent, in, L)

  sp = char(' ' * ones(indent, 1));
  for i=1:numel(L)
    x = L{i};

    if (isa(x,'sym')) %&& isscalar(x))   % wrong for mat sympys
      s = sprintf('%s%s# Load %d: pickle\n', s, sp, i);
      % need to be careful here: pickle might have escape codes
      %s = sprintf('%s%s%s.append(pickle.loads("""%s"""))\n', s, sp, in, x.pickle);
      % subsref is a workaround: otherwise this calls size/numel,
      % starts a recursion if size not cached in the sym.
      idx.type = '.';
      idx.subs = 'pickle';
      %s = sprintf('%s%s%s.append(%s)\n', s, sp, in, x.pickle);
      s = sprintf('%s%s%s.append(%s)\n', s, sp, in, sprintf(subsref(x, idx)));
      % The extra printf around the pickle helps if it still has
      % escape codes (and seems harmless if it does not)

    elseif (ischar(x))
      s = sprintf('%s%s# Load %d: string\n', s, sp, i);
      s = sprintf('%s%s%s.append("%s")\n', s, sp, in, x);

    elseif (islogical(x))
      s = sprintf('%s%s# Load %d: bool\n', s, sp, i);
      if (x)
        s = sprintf('%s%s%s.append(True)\n', s, sp, in);
      else
        s = sprintf('%s%s%s.append(False)\n', s, sp, in);
      end

    elseif (isinteger(x) && isscalar(x))
      s = sprintf('%s%s# Load %d: int type\n', s, sp, i);
      s = sprintf('%s%s%s.append(%d)\n', s, sp, in, x);

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
      s = sprintf('%s%s# Load %d: double\n', s, sp, i);
      s = sprintf('%s%s%s.append(hex2d("%s"))\n', s, sp, in, num2hex(x));

    elseif (iscell(x))
      s = sprintf('%s%s# Load %d: a cell array to list\n', s, sp, i);
      inn = [in 'n'];
      s = sprintf('%s%s%s = []\n', s, sp, inn);
      s = sprintf('%s%s%s.append(%s)\n', s, sp, in, inn);
      s = do_list(s, indent, inn, x);

    elseif (isstruct(x) && isscalar(x))
      s = sprintf('%s%s# Load %d: struct to dict\n', s, sp, i);
      inkeys = [in 'k'];
      invalues = [in 'v'];
      s = sprintf('%s%s%s = []\n', s, sp, inkeys);
      s = do_list(s, indent, inkeys, fieldnames(x));
      s = sprintf('%s%s%s = []\n', s, sp, invalues);
      s = do_list(s, indent, invalues, struct2cell(x));
      s = sprintf('%s%s%s.append(dict(zip(%s,%s)))\n', s, sp, in, inkeys, invalues);

    else
      i, x
      error('don''t know how to move that variable to python');
    end
  end
  s = sprintf('%s%s# end of a list\n', s, sp);
end

