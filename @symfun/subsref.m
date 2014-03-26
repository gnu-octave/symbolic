function out = subsref (f, idx)

  switch idx.type
    case '()'
      out = subs(f, f.vars, idx.subs);
 
    case '.'
      fld = idx.subs;
      if (strcmp (fld, 'vars'))
        out = f.vars;
      else
        %out = sym/subsref(f, idx);
        %out = f.sym.fld;
        warning(' is there a better way to call the superclass fcn?')
        out = subsref(f.sym,idx);
      end

    otherwise
      error ('@symfun/subsref: invalid subscript type ''%s''', idx.type);

  end


