function display(obj)

  d = size (obj);
  if (isscalar (obj))
  %if(1==1)
    fprintf ('%s = (%s) ', inputname (1), class (obj));
    fprintf ('%s', obj.text);

  elseif (length (d) == 2)
    %% 2D Array
    [n m] = deal (d(1), d(2));
    fprintf ('%s = (%s %dx%d matrix) ...\n', inputname (1), ...
             class (obj), n, m);
    fprintf ('%s', obj.text);

 else
    %% nD Array
    % (not possible with sympy matrix)
    fprintf ('%s = (%s nD array) ...\n', inputname (1), class (obj));
    fprintf ('%s', obj.text);
  end


  %% possibly show a bit of the SymPy representation
  display_partial_pickle = true;
  if (display_partial_pickle)
    % trim newlines (if there are any)
    %s = regexprep (obj.pickle, '\n', '\\n');
    s = regexprep (obj.pickle, '\n', '\');
    len = length (s);
    if len > 40
      % FIXME: use some preference for unicode here
      if (1==1)
        s = [s(1:40) '…'];
        %s = ['…' s(13:(13+40)) '…'];
      else
        %s = [s(1:40) '...'];
      end
    end
    fprintf('   "%s"\n', s);
  else
    fprintf('\n');
  end
