function display(obj)
  d = size(obj);

  %if (length(d) == 2) && (d(1) == 1) && (d(2) == 1)
  if (isscalar(obj))
    fprintf ('%s = [%s] ', inputname (1), class (obj));
    fprintf ('%s', obj.text);
    % trim newlines
    %s = regexprep (obj.pickle, '\n', '\\n');
    s = regexprep (obj.pickle, '\n', '\');
    len = length (s);
    if len < 100
      ellipsize = s;
    else
      % todo: ok to use unicode?
      ellipsize = ['…' s(13:45) '…'];
      %ellipsize = [s(1:33) '…'];
      %ellipsize = [s(1:33) '...'];
    end
    fprintf('  [%s]\n', ellipsize);

  elseif (length(d) == 2)
    %% 2D Array
    [n,m] = size(obj);
    fprintf ('%s = [%s %dx%d matrix]\n', inputname (1), ...
             class (obj), n, m);
    for i=1:n
      fprintf ('[')
      fprintf ('%s\t', obj(i,1:end-1).text)
      fprintf ('%s', obj(i,end).text)
      fprintf (']\n')
    end
  else
    %% nD Array: TODO: how do we want this displayed?
    fprintf ('%s = [%s nD array]\n', inputname (1), class (obj));
    disp(struct(obj))
  end
