function out = subsasgn (val, idx, rhs)

  switch idx.type
    case '()'
    %if (isempty(val)) && (strcmp(idx.type, '()'))
    if (isempty(val))
      disp('making a symfun')
      %idx.subs  % the arguments of the symfun
      out = symfun(rhs, idx.subs);
    else
      error('todo: subscript array assignment broken')
    end

    otherwise
      disp('todo: support other forms of subscripted assignment here?')
      idx
      rhs
      val
      warning('broken');
      out = 42;

  end


