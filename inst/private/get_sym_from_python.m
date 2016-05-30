function retS = get_sym_from_python(var_name)
  newl = sprintf('\n');
  ascii = pyeval(strjoin({'sp.pretty(', var_name,', use_unicode=False)'}));
  % workaround https://bitbucket.org/mtmiller/pytave/issues/5
  pyexec (strjoin ( { ['_d = sp.pretty(' var_name ', use_unicode=True)']
                      'if sys.version_info < (3, 0):'
                      '    _d = _d.encode("utf-8")' }, newl));
  unicode = pyeval('_d');
  str = pyeval(strjoin({'sympy.srepr(', var_name,')'}));
  flat = pyeval(strjoin({'str(', var_name,')'}));
  
  str_eval = strjoin({strjoin({'temp = Matrix([', var_name,'])'}),
                      'if isinstance(temp, (sp.Basic, sp.MatrixBase)):',
                      '  _d = list(temp.shape)' ,
                      'elif isinstance(temp, sp.MatrixExpr):' ,
                      '  _d = [float("nan") if (isinstance(r, sp.Basic) and not r.is_Integer) else r for r in temp.shape]',
                      'else:' ,
                      '  _d = [1, 1]'}, newl);
  pyexec(str_eval);
  _d = pyeval('_d');
  
  retS = sym([], str, [_d{1} _d{2}], flat, ascii, unicode);
end