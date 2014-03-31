function out = subsref (f, idx)

  switch idx.type
    case '()'
      error('todo: () subs ref: not for scalar @sym');
 
    case '.'
      fld = idx.subs;
      if (strcmp (fld, 'pickle'))
        out = f.pickle;
      elseif (strcmp (fld, 'text'))
        out = f.text;
      elseif (strcmp (fld, 'extra'))
        out = f.extra;
      else
        error ('@sym/subsref: invalid property ''%s''', fld);
      end

    otherwise
      error ('@sym/subsref: invalid subscript type ''%s''', idx.type);

  end


