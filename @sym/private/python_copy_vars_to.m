function s = python_copy_vars_to(in, varargin)

  s = '';

  if 1==0
  s = sprintf('%s%s = []\n\n', s, in);
  s = do_list(s, 0, in, varargin);

  else
    % todo move these somewhere static/global
  sbtag='<output_block>';
  stag='<output_item>';
  etag='</output_item>';
  ebtag='</output_block>';

  s = sprintf('%stry:\n', s);
  s = sprintf('%s    %s = []\n', s, in);
  s = do_list(s, 4, in, varargin);
  s = sprintf('%s    print "%s"\n', s, sbtag);
  s = sprintf('%s    print "%s"\n', s, stag);
  s = sprintf('%s    print "%s"\n', s, etag);
  s = sprintf('%s    print "%s"\n', s, stag);
  s = sprintf('%s    print "PYTHON: successful variable import"\n', s);
  s = sprintf('%s    print "%s"\n', s, etag);
  s = sprintf('%s    print "%s"\n', s, ebtag);

  s = sprintf('%sexcept:\n', s);
  s = sprintf('%s    print\n', s);
  s = sprintf('%s    print "%s"\n', s, sbtag);
  s = sprintf('%s    print "%s"\n', s, stag);
  s = sprintf('%s    print "%s"\n', s, stag);
  s = sprintf('%s    print "%s"\n', s, etag);
  s = sprintf('%s    print "PYTHON: Error in variable import"\n', s);
  s = sprintf('%s    print "%s"\n', s, etag);
  s = sprintf('%s    print "%s"\n', s, ebtag);
  s = sprintf('%s\n\n', s);
  %s = sprintf('%s    rethrow\n\n', s, ebtag);
  end
end


function s = do_list(s, indent, in, L)

  sp = char(' ' * ones(indent, 1));
  for i=1:length(L)
    x = L{i};
    if (isa(x,'sym') && isscalar(x))
      s = sprintf('%s%s# Load %d: pickle\n', s, sp, i);
      % need to be careful here: pickle might have escape codes
      s = sprintf('%s%s%s.append(pickle.loads("""%s"""))\n', s, sp, in, x.pickle);
    elseif (ischar(x))
      s = sprintf('%s%s# Load %d: string\n', s, sp, i);
      s = sprintf('%s%s%s.append("%s")\n', s, sp, in, x);
    elseif (isnumeric(x) && isscalar(x))
      % TODO: should pass the actual double, see comments elsewhere
      % for this same problem in other direction
      s = sprintf('%s%s# Load %d: double\n', s, sp, i);
      s = sprintf('%s%s%s.append(%.24g)\n', s, sp, in, x);
    elseif (iscell(x))
      s = sprintf('%s%s# Load %d: a cell array to list\n', s, sp, i);
      inn = [in 'n'];
      s = sprintf('%s%s%s = []\n', s, sp, inn);
      s = sprintf('%s%s%s.append(%s)\n', s, sp, in, inn);
      s = do_list(s, inn, x);
    else
      i, x
      error('don''t know how to move that variable to python');
    end
  end
  s = sprintf('%s%s# end of a list\n', s, sp);
end

