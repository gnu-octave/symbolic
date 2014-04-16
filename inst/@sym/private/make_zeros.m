function Z = make_zeros(n,m)
  warning('prob invalid call to make zeros')
  if (nargin==1)
    m = n(2);
    n = n(1);
  end
  z = sym(0);
  Z = z;
  for i=1:n
    for j=1:m
      Z(i,j) = z;
    end
  end
  %Z
