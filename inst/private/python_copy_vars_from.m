function s = python_copy_vars_from(out)

  tag = ipc_misc_params();

  s = '';
  s = sprintf('%sprint ""\n', s);
  s = sprintf('%sprint "%s"\n', s, tag.block);
  s = sprintf('%sprint "%s"\n', s, tag.item);
  s = sprintf('%sprint "%s"\n', s, tag.enditem);
  s = sprintf('%sfor item in %s:\n', s, out);
  s = sprintf('%s    print "%s"\n', s, tag.item);
  s = sprintf('%s    print str("fixme placeholder")\n', s);
  s = sprintf('%s    print "%s"\n', s, tag.enditem);
  s = sprintf('%s    print "%s"\n', s, tag.item);
  s = sprintf('%s    #print pickle.dumps(item, 0)\n', s);
  s = sprintf('%s    #print sp.srepr(item)\n', s);
  s = sprintf('%s    #dbout(("before octcmd", item))\n', s);
  s = sprintf('%s    print "tmp = " + octcmd(item) + ";"\n', s);
  s = sprintf('%s    print "%s"\n\n', s, tag.enditem);
  s = sprintf('%sprint "%s"\n\n', s, tag.endblock);

