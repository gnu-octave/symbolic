function z = minus(x, y)
%-   Minus
%   X - Y subtracts sym Y from sym X.
%

  % -y + x
  z = axplusy(-1, y, x);

