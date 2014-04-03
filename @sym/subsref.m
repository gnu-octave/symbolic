function out = subsref (f, idx)

  switch idx.type
    case '()'
      if (isa(idx.subs, 'sym'))
        error('todo: indexing by @sym, can this happen? what is subindex for then?')
      else
        % what magic stops this from calls subsref recursively?
        out = f(idx.subs{:});
      end
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


