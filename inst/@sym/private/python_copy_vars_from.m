function s = python_copy_vars_from(out)

  sbtag='<output_block>';
  stag='<output_item>';
  etag='</output_item>';
  ebtag='</output_block>';

  s = '';
  s = sprintf('%sprint ""\n', s);
  s = sprintf('%sprint "%s"\n', s, sbtag);
  s = sprintf('%sprint "%s"\n', s, stag);
  s = sprintf('%sprint "%s"\n', s, etag);
  s = sprintf('%sfor item in %s:\n', s, out);
  s = sprintf('%s    print "%s"\n', s, stag);
  s = sprintf('%s    print str("fixme placeholder")\n', s);
  s = sprintf('%s    print "%s"\n', s, etag);
  s = sprintf('%s    print "%s"\n', s, stag);
  s = sprintf('%s    #print pickle.dumps(item, 0)\n', s);
  s = sprintf('%s    #print sp.srepr(item)\n', s);
  s = sprintf('%s    #dbout(("before octcmd", item))\n', s);
  s = sprintf('%s    print "tmp = " + octcmd(item) + ";"\n', s);
  s = sprintf('%s    print "%s"\n\n', s, etag);
  s = sprintf('%sprint "%s"\n\n', s, ebtag);

