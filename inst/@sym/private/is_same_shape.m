function t = is_same_shape(x,y)
%IS_SAME_SHAPE  Inputs have same shape
%   Note does not say same type

  d1 = size(x);
  d2 = size(y);
  t = ( ...
      (length(d1) == length(d2)) && ...
      (all(d1 == d2)) ...
      );

