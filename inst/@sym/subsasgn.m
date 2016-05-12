%% Copyright (C) 2014, 2015 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypeop  Method   @@sym {@var{f} =} subsasgn (@var{f}, @var{idx}, @var{rhs})
%% @deftypeopx Operator @@sym {} {@var{f}(@var{i}) = @var{rhs}} {}
%% @deftypeopx Operator @@sym {} {@var{f}(@var{i}, @var{j}) = @var{rhs}} {}
%% @deftypeopx Operator @@sym {} {@var{f}(@var{i}:@var{j}) = @var{rhs}} {}
%% @deftypeopx Operator @@sym {} {@var{f}(@var{x}) = @var{symexpr}} {}
%% Assign to entries of a symbolic array.
%%
%% Examples:
%% @example
%% @group
%% A = sym([10 11 12]);
%% A(3) = 44
%%   @result{} A = (sym) [10  11  44]  (1×3 matrix)
%%
%% A(1:2) = [42 43]
%%   @result{} (sym) [42  43  44]  (1×3 matrix)
%%
%% A(1, 1) = 41
%%   @result{} (sym) [41  43  44]  (1×3 matrix)
%% @end group
%% @end example
%%
%% This method also gets called when creating @@symfuns:
%% @example
%% @group
%% syms x
%% f(x) = 3*x^2
%%   @result{} f(x) = (symfun)
%%          2
%%       3⋅x
%% @end group
%% @end example
%%
%% @seealso{@@sym/subsref, @@sym/subindex, @@sym/end, symfun}
%% @end deftypeop

function out = subsasgn (val, idx, rhs)

  switch idx.type
    case '()'
      %% symfun constructor
      % f(x) = rhs
      %   f is val
      %   x is idx.subs{1}
      % This also gets called for "syms f(x)"

      if (isa(idx.subs{1}, 'sym'))  % f(sym) = ..., define symfun
        if (~isa(rhs, 'sym'))
          % rhs is, e.g., a double, then we call the constructor
          rhs = sym(rhs);
        end
        out = symfun(rhs, idx.subs);

      else   % f(double) = ..., array assignment
        out = mat_replace(val, idx.subs, sym(rhs));
      end

    case '.'
      assert( isa(rhs, 'sym'))
      assert( ~isa(idx.subs, 'sym'))
      assert( ~isa(val, 'sym'))
      val.(idx.subs) = rhs;
      out = val;

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

%% bug: assignment to column vector used to fail
%!test
%! A = sym(zeros(3,1));
%! A(1) = 5;

%% symfun creation (generic function)
%!test
%! syms x
%! g(x) = x*x;
%! assert(isa(g,'symfun'))

%% symfun creation (generic function)
%!test
%! syms x g(x)
%! assert(isa(g,'symfun'))

%% symfun creation when g already exists and is a sym/symfun
%!test
%! syms x
%! g = x;
%! syms g(x)
%! assert(isa(g,'symfun'))
%! clear g
%! g(x) = x;
%! g(x) = x*x;
%! assert(isa(g,'symfun'))


%!test
%! % older expansion tests
%! syms x
%! f = [2*x 3*x];
%! f(2) = 4*x;
%! assert (isequal (f, [2*x 4*x]))
%! f(2) = 2;
%! assert (isequal(f, [2*x 2]))
%! g = f;
%! g(1,3) = x*x;
%! assert (isequal(g, [2*x 2 x^2]))
%! g = f;
%! g(3) = x*x;
%! assert (isequal(g, [2*x 2 x^2]))
%! g = f;
%! g(3) = 4;
%! assert (isequal(g, [2*x 2 4]))


%!test
%! % older slicing tests
%! syms x
%! f = [1 x^2 x^4];
%! f(1:2) = [x x];
%! assert (isequal(  f, [x x x^4]  ))
%! f(1:2) = [1 2];
%! assert (isequal(  f, [1 2 x^4]  ))
%! f(end-1:end) = [3 4];
%! assert (isequal(  f, [1 3 4]  ))
%! f(3:4) = [10 11];
%! assert (isequal(  f, [1 3 10 11]  ))
%! f(end:end+1) = [12 14];
%! assert (isequal(  f, [1 3 10 12 14]  ))

%!test
%! % struct.str = sym, sometimes calls subsasgn
%! d = struct();
%! syms x
%! d.a = x;
%! assert (isa (d, 'struct'))
%! assert (isequal (d.a, x))
%! d.('a') = x;
%! assert (isa (d, 'struct'))
%! assert (isequal (d.a, x))
%! d = setfield(d, 'a', x);
%! assert (isa (d, 'struct'))
%! assert (isequal (d.a, x))
%! % at least on Oct 3.8, this calls sym's subsasgn
%! d = struct();
%! d = setfield(d, 'a', x);
%! assert (isa (d, 'struct'))
%! assert (isequal (d.a, x))

%!test
%! % bool scalar assignments of true/false into sym
%! a = sym([1 2 x 3]);
%! b = [1 2 10 4];
%! e = a == b;
%! assert (logical (e(2)))
%! e(2) = false;
%! assert (~logical (e(2)))

%!test
%! % bool vector assignments of true/false into sym
%! a = sym([1 2 x 3]);
%! b = [1 2 10 4];
%! e = a == b;
%! e(1:2) = [true true];
%! assert (isequal (e, [sym(1)==1  sym(2)==2  x==10  sym(3)==4]))

%!test
%! % bool scalar promoted to vector assignments into sym
%! a = sym([1 2 x 3]);
%! b = [1 2 10 4];
%! e = a == b;
%! e(1:2) = true;
%! assert (isequal (e, [sym(1)==1  sym(2)==2  x==10  sym(3)==4]))


%% 2D arrays from mat_mask_asgn

%!shared a, b, I
%! b = [1:4]; b = [b; 3*b; 5*b];
%! a = sym(b);
%! I = rand(size(b)) > 0.5;

%!test
%! A = a;  A(I) = 2*b(I);
%! B = b;  B(I) = 2*b(I);
%! assert (isequal (A, B))

%!test
%! % scalar RHS
%! A = a;  A(I) = 17;
%! B = b;  B(I) = 17;
%! assert (isequal (A, B))

%!warning <unusual>
%! % strange non-vector (matrix) RHS ("rhs2"), should be warning
%! I = logical([1 0 1 0; 0 1 0 1; 1 0 1 0]);
%! rhs2 = reshape(2*b(I), 2, 3);  % strange bit
%! A = a;
%! A(I) = rhs2;

%!test
%! % nonetheless, above strange case should give right answer
%! I = logical([1 0 1 0; 0 1 0 1; 1 0 1 0]);
%! rhs = 2*b(I);
%! rhs2 = reshape(rhs, 2, 3);
%! s = warning ('off', 'OctSymPy:subsagn:rhs_shape');
%! A0 = a; A1 = a;
%! A0(I) = rhs;
%! A1(I) = rhs2;
%! warning (s)
%! assert (isequal (A0, A1))


%% Tests from mat_rclist_asgn

%!shared AA, BB
%! BB = [1 2 3; 4 5 6];
%! AA = sym(BB);

%!test
%! A = AA; B = BB;
%! B([1 6]) = [8 9];
%! A([1 6]) = [8 9];
%! assert (isequal (A, B))

%!test
%! % rhs scalar
%! A = AA; B = BB;
%! B([1 6]) = 88;
%! A([1 6]) = 88;
%! assert (isequal (A, B))

%!test
%! % If rhs is not a vector, make sure col-based access works
%! rhs = [18 20; 19 21];
%! A = AA; B = BB;
%! B([1 6]) = 88;
%! A([1 6]) = 88;
%! B([1 2 3 4]) = rhs;
%! A([1 2 3 4]) = rhs;
%! assert (isequal (A, B))

%!test
%! % Growth
%! A = AA; B = BB;
%! A(1,5) = 10;
%! B(1,5) = 10;
%! assert (isequal (A, B))

%% End of mat_* tests
