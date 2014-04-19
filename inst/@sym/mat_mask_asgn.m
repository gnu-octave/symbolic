function z = mat_mask_asgn(A, I, B)
%MAT_MASK_ASGN  Private helper routine

  if (~islogical(I))
    error('subscript indices must be either positive integers or logicals')
  end
  if (numel(A) ~= numel(I))
    error('size A not compatible w/ size I in A(I)')
  end
  if (numel(B) == 1)
    B = B*ones(nnz(I),1);
  end
  if (nnz(I) ~= numel(B))
    error('not enough/too much in B')
  end

  if (~(is_same_shape(A,I)))
    warning('A and I in A(I) not same shape: did you intend this?')
  end
  if (~isvector(B))
    % apparently this is ok
    warning('B not vector is A(I)=B: this is unusual, did you intend this?')
  end

  % I think .T makes a copy, but be careful: in general may need a
  % .copy() here
  cmd = [ 'def fcn(_ins):\n'  ...
          '    (A,mask,B) = _ins\n'  ...
          '    # transpose b/c SymPy is row-based\n' ...
          '    AT = A.T\n' ...
          '    maskT = mask.T\n' ...
          '    BT = B.T\n' ...
          '    j = 0\n' ...
          '    for i in range(0,len(A)):\n'  ...
          '        if maskT[i] > 0:\n' ...
          '            AT[i] = BT[j]\n'  ...
          '            j = j + 1\n' ...
          '    return (AT.T,)\n' ];

  % FIXME: not optimal, but we don't have bool -> sym yet
  if islogical(I)
    I = double(I);
  end
  z = python_sympy_cmd(cmd, sym(A), sym(I), sym(B));
end



%% 2D arrays
%!shared a,b,I
%! b = [1:4]; b = [b; 3*b; 5*b];
%! a = sym(b);
%! I = rand(size(b)) > 0.5;

%!test
%! A = mat_mask_asgn(a,I, 2*b(I));
%! B = b;  B(I) = 2*b(I);
%! assert(isequal( A, B ))

%!test  % scalar RHS
%! A = mat_mask_asgn(a,I, 17);
%! B = b;  B(I) = 17;
%! assert(isequal( A, B ))

%!test  % non-vector RHS ("rhs2")
%! I = logical([1 0 1 0; 0 1 0 1; 1 0 1 0]);
%! rhs = 2*b(I);
%! rhs2 = reshape(rhs, 2, 3);
%! disp('*** One warning expected: ***');
%! A = mat_mask_asgn(a,I, rhs2);
%! B = b;  B(I) = rhs;
%! assert(isequal( A, B ))
