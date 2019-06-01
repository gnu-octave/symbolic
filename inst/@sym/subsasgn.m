%% Copyright (C) 2014-2017, 2019 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016 Abhinav Tripathi
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
%%   @result{} A = (sym) [42  43  44]  (1×3 matrix)
%%
%% A(1, 1) = 41
%%   @result{} A = (sym) [41  43  44]  (1×3 matrix)
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

      all_syms = true;
      for i = 1:length(idx.subs)
        all_syms = all_syms && isa(idx.subs{i}, 'sym');
      end
      if (all_syms)
        cmd = { 'L, = _ins'
                'return all([x is not None and x.is_Symbol for x in L])' };
        all_Symbols = pycall_sympy__ (cmd, idx.subs);
      end
      if (all_syms && all_Symbols)
        %% Make a symfun
        if (~isa(rhs, 'sym'))
          % rhs is, e.g., a double, then we call the constructor
          rhs = sym(rhs);
        end
        out = symfun(rhs, idx.subs);

      else
        %% Not symfun: e.g., f(double) = ..., f(sym(2)) = ...,
        % convert any sym subs to double and do array assign
        for i = 1:length(idx.subs)
          if (isa(idx.subs{i}, 'sym'))
            idx.subs{i} = double(idx.subs{i});
          end
        end
        for i = 1:length(idx.subs)
          if (~ is_valid_index(idx.subs{i}))
            error('OctSymPy:subsref:invalidIndices', ...
                  'invalid indices: should be integers or boolean');
          end
        end
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

%!shared

%!test
%! b = 1:4; b = [b; 2*b; 3*b];
%! a = sym(b);
%! rhs = [10 11; 12 13];
%! a([1:2],[1:2]) = rhs;
%! b([1:2],[1:2]) = rhs;
%! assert(isequal( a, b ))
%! a(1:2,1:2) = rhs;
%! assert(isequal( a, b ))

%!test
%! % slice :
%! b = 1:4; b = [b; 2*b];
%! a = sym(b);
%! rhs = [10 11; 12 13];
%! a(:,2:3) = rhs;
%! b(:,2:3) = rhs;
%! assert(isequal( a, b ))

%!test
%! % grow 2D
%! b = 1:4; b = [b; 2*b];
%! a = sym(b);
%! rhs = [10 11; 12 13];
%! a([1 end+1],end:end+1) = rhs;
%! b([1 end+1],end:end+1) = rhs;
%! assert(isequal( a, b ))

%!test
%! % grow from nothing
%! clear a
%! a(3) = sym (1);
%! b = sym ([0 0 1]);
%! assert (isequal (a, b))

%!test
%! % grow from nothing, 2D
%! clear a
%! a(2, 3) = sym (1);
%! b = sym ([0 0 0; 0 0 1;]);
%! assert (isequal (a, b))

%!test
%! % linear indices of 2D
%! b = 1:4; b = [b; 2*b; 3*b];
%! a = sym(b);
%! b(1:4) = [10 11 12 13];
%! a(1:4) = [10 11 12 13];
%! assert(isequal( a, b ))
%! b(1:4) = [10 11; 12 13];
%! a(1:4) = [10 11; 12 13];
%! assert(isequal( a, b ))

%!error <mismatch>
%! % Wrong shape matrix RHS: Matlab/Octave don't allow this on doubles.
%! % Matlab SMT 2013b gets it wrong.  We throw an error.
%! rhs = [10 11; 12 13];
%! a = sym (magic (3));
%! a(1:2,1:2) = rhs(:);

%!test
%! % Issue #963: vector RHS with diff orientation from 2D indexing
%! b = 1:4; b = [b; 2*b; 3*b];
%! a = sym(b);
%! b(1:2:3, 1) = 11:2:13;
%! a(1:2:3, 1) = sym(11:2:13);
%! assert (isequal (a, b))
%! b(1:2:3, 1) = 1:2:3;
%! a(1:2:3, 1) = 1:2:3;
%! assert (isequal (a, b))

%!test
%! % Issue #963: vector RHS with diff orientation from 2D indexing
%! a = sym (magic (3));
%! b = a;
%! a(1:2:3, 2) = [14 15];
%! b(1:2:3, 2) = [14; 15];
%! assert (isequal (a, b))
%! a(2, 1:2:3) = [24 25];
%! b(2, 1:2:3) = [24; 25];
%! assert (isequal (a, b))

%!test
%! % 1D growth and 'end'
%! g = sym([1 2 3]);
%! g(3:4) = [67 68];
%! g(end:end+1) = [12 14];
%! assert(isequal( g, [1 2 67 12 14] ))

%!test
%! % expanding empty and scalar
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

%!shared

%!test
%! % logical with all false
%! syms x
%! y = x;
%! y(false) = 6;
%! assert(isequal( y, x ));
%! a = [x x];
%! a([false false]) = [6 6];
%! assert(isequal( a, [x x] ));

%!test
%! % issue #18, scalar access
%! syms x
%! x(1) = sym(6);
%! assert(isequal( x, sym(6) ));
%! x(1) = 6;
%! assert(isequal( x, sym(6) ));
%! x(true) = 88;
%! assert(isequal( x, sym(88) ));

%!test
%! % bug: assignment to column vector used to fail
%! A = sym(zeros(3,1));
%! A(1) = 5;

%!test
%! % symfun creation (generic function)
%! syms x
%! g(x) = x*x;
%! assert(isa(g,'symfun'))

%!test
%! % symfun creation (generic function)
%! syms x g(x)
%! assert(isa(g,'symfun'))

%!test
%! % symfun creation when g already exists and is a sym/symfun
%! syms x
%! g = x;
%! syms g(x)
%! assert(isa(g,'symfun'))
%! clear g
%! g(x) = x;
%! g(x) = x*x;
%! assert(isa(g,'symfun'))

%!test
%! % Issue #443: assignment with sym indices
%! A = sym([10 11]);
%! A(sym(1)) = 12;
%! assert (isequal (A, sym([12 11])))

%!test
%! % Issue #443: assignment with sym indices
%! A = sym([10 11]);
%! A(sym(1), 1) = 12;
%! assert (isequal (A, sym([12 11])))
%! A(sym(1), sym(1)) = 13;
%! assert (isequal (A, sym([13 11])))

%!test
%! % Issue #443: assignment with sym indices, increase size
%! A = sym([10 11]);
%! A(sym(2), 1) = 12;
%! assert (isequal (A, sym([10 11; 12 0])))

%!error
%! % Issue #443
%! A = sym([10 11]);
%! A(2, sym('x')) = sym(12);

%!error
%! % Issue #443
%! A = sym([10 11]);
%! A(sym(2), sym('x')) = sym(12);

%!error <integers>
%! % issue #445
%! A = sym([10 11]);
%! A(1.1) = 13

%!error <integers>
%! % issue #445
%! A = sym([10 11]);
%! A(sym(pi)) = 13

%!error <integers>
%! % issue #445
%! A = sym([1 2; 3 4]);
%! A(1.3, 1.2) = 13


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
%! syms x
%! a = sym([1 2 x 3]);
%! b = [1 2 10 4];
%! e = a == b;
%! assert (logical (e(2)))
%! e(2) = false;
%! assert (~logical (e(2)))

%!test
%! % bool vector assignments of true/false into sym
%! syms x
%! a = sym([1 2 x 3]);
%! b = [1 2 10 4];
%! e = a == b;
%! e(1:2) = [true true];
%! assert (isequal (e, [sym(1)==1  sym(2)==2  x==10  sym(3)==4]))

%!test
%! % bool scalar promoted to vector assignments into sym
%! syms x
%! a = sym([1 2 x 3]);
%! b = [1 2 10 4];
%! e = a == b;
%! e(1:2) = true;
%! assert (isequal (e, [sym(1)==1  sym(2)==2  x==10  sym(3)==4]))


%% 2D arrays from mat_mask_asgn

%!shared a, b, I
%! b = [1:4]; b = [b; 3*b; 5*b];
%! a = sym(b);
%! I = mod (b, 5) > 1;

%!test
%! A = a;  A(I) = 2*b(I);
%! B = b;  B(I) = 2*b(I);
%! assert (isequal (A, B))

%!test
%! % scalar RHS
%! A = a;  A(I) = 17;
%! B = b;  B(I) = 17;
%! assert (isequal (A, B))

%!test
%! % nonetheless, above strange case should give right answer
%! I = logical([1 0 1 0; 0 1 0 1; 1 0 1 0]);
%! rhs = 2*b(I);
%! rhs2 = reshape(rhs, 2, 3);
%! A0 = a; A1 = a;
%! A0(I) = rhs;
%! A1(I) = rhs2;
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

%!shared

%!test
%! % Check row deletion 1D
%! a = sym([1; 3; 5]);
%! b = sym([3; 5]);
%! a(1) = [];
%! assert( isequal( a, b))

%!test
%! % Check column deletion 1D
%! a = sym([1, 4, 8]);
%! b = sym([4, 8]);
%! a(1) = [];
%! assert( isequal( a, b))

%!test
%! % Check row deletion 2D
%! a = sym([1, 2; 3, 4]);
%! b = sym([3, 4]);
%! a(1, :) = [];
%! assert( isequal( a, b))

%!test
%! % Check column deletion 2D
%! a = sym([1, 2; 3, 4]);
%! b = sym([2; 4]);
%! a(:, 1) = [];
%! assert( isequal( a, b))

%!test
%! % General assign
%! a = sym([1, 2; 3, 4]);
%! b = sym([5, 5; 5, 5]);
%! a(:) = 5;
%! assert( isequal( a, b))

%!test
%! % Empty matrix
%! a = sym([1, 2; 3, 4]);
%! a(:) = [];
%! assert( isequal( a, sym([])))

%!test
%! % Disassemble matrix
%! a = sym([1 2; 3 4; 5 6]);
%! b = sym([3 5 2 4 6]);
%! a(1) = [];
%! assert (isequal (a, b));

%!error <null assignment>
%! a = sym([1, 2; 3, 4]);
%! a(1, 2) = [];

%!test
%! % Issue #963: scalar asgn to empty part of matrix
%! A = sym (magic (3));
%! B = A;
%! A(1, []) = 42;
%! assert (isequal (A, B))
%! A([], 2) = 42;
%! assert (isequal (A, B))
%! A([]) = 42;
%! assert (isequal (A, B))
%! A([], []) = 42;
%! assert (isequal (A, B))
%! A(2:3, []) = 42;
%! assert (isequal (A, B))
%! A([], 2:3) = 42;
%! assert (isequal (A, B))
%! A(:, []) = 42;
%! assert (isequal (A, B))
%! A([], :) = 42;
%! assert (isequal (A, B))

%!error
%! % TODO: do we care what error?
%! A = sym (magic (3));
%! A(2:3, []) = [66; 66];

%!error
%! A = sym (magic (3));
%! A([]) = [66; 66];

%!error
%! A = sym (magic (3));
%! A([], 1) = [66; 66];

%!test
%! % Issue #966: empty indexing, empty RHS, A unchanged
%! B = magic(3);
%! A = sym(B);
%! A(1, []) = [];
%! assert (isequal (A, B))
%! A([], 2) = [];
%! assert (isequal (A, B))
%! A([], []) = [];
%! assert (isequal (A, B))
%! A(2:3, []) = [];
%! assert (isequal (A, B))
%! A([], 2:3) = [];
%! assert (isequal (A, B))
%! A(:, []) = [];
%! assert (isequal (A, B))
%! A([], :) = [];
%! assert (isequal (A, B))

%!test
%! % Issue 967
%! B = [1 2; 3 4];
%! A = sym(B);
%! A([]) = [];
%! assert (isequal (A, B))

%!test
%! % Issue #965
%! a = sym(7);
%! a([]) = [];
%! assert (isequal (a, sym(7)))

%!test
%! % Issue #965
%! a = sym(7);
%! a([]) = 42;
%! assert (isequal (a, sym(7)))

%!error
%! % Issue #965
%! a = sym(7);
%! a([]) = [42 42]


%% Tests from mat_replace

%!test
%! % 2D indexing with length in one dimension more than 2
%! a = sym ([1 2; 3 4; 5 6]);
%! indices = [1 4; 2 5; 3 6];
%! b = [10 11; 12 13; 14 15];
%! a(indices) = b;
%! assert (isequal (a, sym (b)));

%!test
%! A = sym ([0 0 0]);
%! indices = [false true false];
%! A(indices) = 1;
%! assert (isequal (A, sym ([0 1 0])));
%! A(indices) = [];
%! assert (isequal (A, sym ([0 0])));
%! indices = [false false];
%! A(indices) = [];
%! assert (isequal (A, sym ([0 0])));

%!shared a, b
%! a = [1 2 3 5; 4 5 6 9; 7 5 3 2];
%! b = sym (a);

%!test
%! A = a; B = b;
%! A(true) = 0;
%! B(true) = 0;
%! assert (isequal (A, B))

%!test
%! A = a; B = b;
%! A(false) = 0;
%! B(false) = 0;
%! assert (isequal (A, B))

%!test
%! c = [false true];
%! A = a; B = b;
%! A(c) = 0; B(c) = 0;
%! assert (isequal (A, B))
%! d = c | true;
%! A(d) = 1; B(d) = 1;
%! assert (isequal (A, B))
%! d = c & false;
%! A(d) = 2; B(d) = 2;
%! assert (isequal (A, B))

%!test
%! c = [false true false true; true false true false; false true false true];
%! A = a; B = b;
%! A(c) = 0; B(c) = 0;
%! assert (isequal (A, B))
%! d = c | true;
%! A(d) = 1; B(d) = 1;
%! assert (isequal (A, B))
%! d = c & false;
%! A(d) = 2; B(d) = 2;
%! assert (isequal (A, B))

%!test
%! c = [false true false true false];
%! A = a; B = b;
%! A(c) = 0; B(c) = 0;
%! assert (isequal (A, B))
%! d = c | true;
%! A(d) = 1; B(d) = 1;
%! assert (isequal (A, B))
%! d = c & false;
%! A(d) = 2; B(d) = 2;
%! assert (isequal (A, B))

%!test
%! c = [false; true; false; true; false];
%! A = a; B = b;
%! A(c) = 0; B(c) = 0;
%! assert (isequal (A, B))
%! d = c | true;
%! A(d) = 1; B(d) = 1;
%! assert (isequal (A, B))
%! d = c & false;
%! A(d) = 2; B(d) = 2;
%! assert (isequal (A, B))

%!test
%! c = [false true; false true; true false];
%! A = a; B = b;
%! A(c) = 0; B(c) = 0;
%! assert (isequal (A, B))
%! d = c | true;
%! A(d) = 1; B(d) = 1;
%! assert (isequal (A, B))
%! d = c & false;
%! A(d) = 2; B(d) = 2;
%! assert (isequal (A, B))

%% End of mat_* tests
