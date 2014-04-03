function out = subsasgn (val, idx, rhs)

  switch idx.type
    case '()'
      if (isa(idx.subs{1}, 'sym'))  % f(sym) = ..., define symfun
        if (isempty(val))
          disp('making a symfun')
        else
          disp('replacing a symfun')
        end
        %idx.subs  % the arguments of the symfun
        if (iscell(rhs.text) && strcmp(rhs.text{1}, 'UGLY HACK'))
          disp('ugly hack concluded')
          rhs = make_undecl_symfun_rhs(rhs.text{2}, idx.subs);
        end
        out = symfun(rhs, idx.subs);

      else   % f(double) = ..., array assignment
        % black magic for me, how does it call a superclass ()?
        out = val;
        out(idx.subs{:}) = sym(rhs);
      end

    otherwise
      disp('todo: support other forms of subscripted assignment here?')
      idx
      rhs
      val
      warning('broken');
      out = 42;

  end


