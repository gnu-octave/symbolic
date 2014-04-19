function out = subsref (f, idx)
%SUBSREF  Access entries of a symbolic array

  %disp('call to @sym/subsref')
  switch idx.type
    case '()'
      if (isa(idx.subs, 'sym'))
        error('todo: indexing by @sym, can this happen? what is subindex for then?')
      else
        out = mat_access(f, idx.subs);
      end
    case '.'
      fld = idx.subs;
      if (strcmp (fld, 'pickle'))
        out = f.pickle;
      elseif (strcmp (fld, 'text'))
        out = f.text;
      elseif (strcmp (fld, 'flattext'))
        out = f.flattext;
      % not part of the interface
      %elseif (strcmp (fld, 'size'))
      %  out = f.size;
      %elseif (strcmp (fld, 'extra'))
      %  out = f.extra;
      else
        error ('@sym/subsref: invalid property ''%s''', fld);
      end

    otherwise
      error ('@sym/subsref: invalid subscript type ''%s''', idx.type);

  end

end

%!shared a,b
%! b = [1:4];
%! a = sym(b);
%!assert(isequal( a(1), b(1) ))
%!assert(isequal( a(2), b(2) ))
%!assert(isequal( a(4), b(4) ))
%!assert(isempty( a([]) ))

%!shared a,b
%! b = [1:4];  b = [b; 3*b; 5*b];
%! a = sym(b);
%!assert(isequal( a(1), b(1) ))
%!assert(isequal( a(2), b(2) ))
%!assert(isequal( a(4), b(4) ))
%!assert(isequal( a(:,:), a ))
%!assert(isequal( a(1:2,1:3), a(1:2,1:3) ))
%!assert(isequal( a(1:2:3,[1 2 4]), b(1:2:3,[1 2 4]) ))
%!assert(isequal( a(1:2:3,[4 2 3 1]), b(1:2:3,[4 2 3 1]) ))
% repeats
%!assert(isequal( a(1:2:3,[4 1 1 1]), b(1:2:3,[4 1 1 1]) ))

%!assert(isequal( a([],:), b([],:) ))
%!assert(isequal( size(a([],:)), [0 4] ))
%!assert(isequal( a(1:2,[]), b(1:2,[]) ))
%!assert(isequal( size(a(1:2,[])), [2 0] ))
%!assert(isempty( a(1:2,[]) ))
%!assert(isempty( a([],[]) ))
%!assert(isequal( a([],[]), sym([]) ))
%!assert(~isequal( a(1:2,[]), sym([]) ))

%!shared e
%! e = sym([1 3 5; 2 4 6]);
%!assert(isequal( e(:), sym((1:6)') ))
%!assert(isequal( e([1 2 3]), sym([1; 2; 3]) ))
%!assert(isequal( e([1; 3; 4]), sym([1; 3; 4]) ))
%!assert(isempty( e([]) ))
%!assert(isequal( e([]), sym([]) ))

