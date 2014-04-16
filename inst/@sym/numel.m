function n = numel(x)
%NUMEL   Number of elements in symbolic array

  %disp('numel call')
  d = size(x);
  n = prod(d);

