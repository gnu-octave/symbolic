function obj = check_and_convert()
  newl = sprintf('\n');
  
  str_check_is_sym = strjoin({'if temp is None or isinstance(temp, (sp.Basic, sp.MatrixBase)):',
                              '  is_sym = True',
                              'else:',
                              '  is_sym = False'},newl);
  pyexec(str_check_is_sym);
  is_sym = pyeval('is_sym');
  
  if is_sym
    ascii = pyeval('sp.pretty(_outs[0], use_unicode=False)');
    unicode = pyeval('sp.pretty(_outs[0], use_unicode=True)');
    str = pyeval('sympy.srepr(_outs[0])');
    flat = pyeval('str(_outs[0])');
    
    str_eval = strjoin({'temp = Matrix([_outs[0]])',
                        'if isinstance(temp, (sp.Basic, sp.MatrixBase)):',
                        '  _d = temp.shape' ,
                        'elif isinstance(temp, sp.MatrixExpr):' ,
                        '  _d = [float("nan") if (isinstance(r, sp.Basic) and not r.is_Integer) else r for r in temp.shape]',
                        'else:' ,
                        '  _d = (1, 1)',
                        '#function call to pyobj with params not implemented yet',
                        'd0 = _d[0]',
                        'd1 = _d[1]'}, newl);
    pyexec(str_eval);
    _d = [1 1];
    _d(1) = pyeval('d0');
    _d(2) = pyeval('d1');
    
    obj = sym([], str, [_d(1) _d(2)], flat, ascii, unicode);
  else
    obj = pyeval('_outs[0]');
  end
end