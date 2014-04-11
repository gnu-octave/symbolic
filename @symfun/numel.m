function n = numel(f)
%NUMEL   Number of elements in symbolic array
%   todo: why do i need this? why is it called so much?

  %disp('symfun numel call') %, hardcoded to 1')
  %n = 1;

  n = numel(f.sym);
