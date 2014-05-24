function tok = mystrsplit(str, sep)
% like strsplit but less erratic across old octave/matlab

  n = [];
  for i = 1:length(sep)
    n = [n strfind(str, sep{i})];
  end

  n = sort(unique(n));
  endd = [n-1  length(str)];
  start = [1  n+1];

  tok = {};
  c = 0;
  for i=1:length(start)
    c = c + 1;
    tok{c} = str(start(i):endd(i));
  end
end
