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
      disp('FIXME: do we need to support any other forms of subscripted assignment?')
      idx
      rhs
      val
      error('broken');
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

%!shared a,b
%! b = 1:4; b = [b; 2*b; 3*b];
%! a = sym(b);
%!test
%! rhs = [10 11; 12 13];
%! a([1:2],[1:2]) = rhs;
%! b([1:2],[1:2]) = rhs;
%! assert(isequal( a, b ))
%! a(1:2,1:2) = rhs;
%! assert(isequal( a, b ))

%% slice :
%!shared a,b
%! b = 1:4; b = [b; 2*b];
%! a = sym(b);
%!test
%! rhs = [10 11; 12 13];
%! a(:,2:3) = rhs;
%! b(:,2:3) = rhs;
%! assert(isequal( a, b ))

%% grow 2D
%!shared a,b
%! b = 1:4; b = [b; 2*b];
%! a = sym(b);
%!test
%! rhs = [10 11; 12 13];
%! a([1 end+1],end:end+1) = rhs;
%! b([1 end+1],end:end+1) = rhs;
%! assert(isequal( a, b ))

%% linear indices of 2D
%!test
%! b = 1:4; b = [b; 2*b; 3*b];
%! a = sym(b);
%! b(1:4) = [10 11 12 13];
%! a(1:4) = [10 11 12 13];
%! assert(isequal( a, b ))
%! b(1:4) = [10 11; 12 13];
%! a(1:4) = [10 11; 12 13];
%! assert(isequal( a, b ))

%% Wrong shape RHS
% Matlab/Octave don't allow this on doubles, but if you do
% this is the right answer (Matlab SMT 2013b gets it wrong)
% I will disable it too.
%test
% rhs = [10 11; 12 13];
% b(1:2,1:2) = rhs;
% a(1:2,1:2) = rhs(:);
% assert(isequal( a, b ))

%% 1D growth and 'end'
%!test
%! g = sym([1 2 3]);
%! g(3:4) = [67 68];
%! g(end:end+1) = [12 14];
%! assert(isequal( g, [1 2 67 12 14] ))

%% expanding empty and scalar
%!test
%! syms x
%! c = sym([]);
%! c(1) = x;
%! assert(isequal( c, x ))
%! c(2) = 2*x;
%! assert(isequal( c, [x 2*x] ))

%% 2d logical indexing, ref and asgn
%!shared a,b,I,J
%! b = 1:4; b = [b; 3*b; 5*b];  a = sym(b);
%! I = logical([1 0 1]);
%! J = logical([1 0 1 0]);
%!assert(isequal( a(I,J), b(I,J) ))
%!test
%! rhs = [90 91; 92 93];
%! b(I, J) = rhs;
%! a(I, J) = rhs;
%! assert(isequal( a, b ))
%!test
%! b(I, J) = 100;
%! a(I, J) = 100;
%! assert(isequal( a, b ))

%!shared x
%! syms x

%% logical with all false
%!test
%! y = x;
%! y(false) = 6;
%! assert(isequal( y, x ));
%! a = [x x];
%! a([false false]) = [6 6];
%! assert(isequal( a, [x x] ));

%% issue 18, scalar access
%!test
%! x(1) = sym(6);
%! assert(isequal( x, sym(6) ));
%! x(1) = 6;
%! assert(isequal( x, sym(6) ));
%! x(true) = 88;
%! assert(isequal( x, sym(88) ));

