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
        out = mat_replace(val, idx.subs, sym(rhs));
      end

    otherwise
      disp('todo: support other forms of subscripted assignment here?')
      idx
      rhs
      val
      warning('broken');
      out = 42;

  end
end


%!shared a,b
%! b = [1:4];
%! a = sym(b);
%!test a(1) = 10; b(1) = 10;
%! assert(isequal( a, b ))
%!test I = logical([1 0 1 0]);
%! a(I) = 2; b(I) = 2;
%! assert(isequal( a, b ))
%!test I = logical([1 0 1 0]);
%! a(I) = [2 4]; b(I) = [2 4];
%! assert(isequal( a, b ))
%!test I = logical([1 0 1 0]);
%! a(I) = [2; 4]; b(I) = [2; 4];
%! assert(isequal( a, b ))
