function z = isprime(x)

  cmd = [ '(x,) = _ins\n'   ...
          'if x.is_Matrix:\n'   ...
          '    z = x.applyfunc(lambda a: sp.isprime(a))\n'  ...
          'else:\n'   ...
          '    z = sp.isprime(x)\n'  ...
          'return (z,)' ];

  z = python_cmd (cmd, x);

  %% postproccess to logical
  % FIXME: Issue #27
  % FIXME: but anyway, this is a bit horrid, not the recommended approach
  if (numel(z) > 1)
    tf = zeros(size(z), 'logical');
    for i=1:numel(z)
      %rhs = subsref(z, substruct('()', {i}))
      rhs = python_cmd ('return _ins[0][_ins[1]] == True,', z, i-1);
      tf(i) = rhs;
    end
    z = tf;
  end
end


%!assert (isprime (sym(5)))
%!assert (~isprime (sym(4)))
%!test
%! a = [5 7 6; 1 2 337];
%! assert (isprime (a), [true true false; false true true])