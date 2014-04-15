function display(obj)

  %% Settings
  display_snippet = false;
  % FIXME: how to access format compact/loose setting?
  loose = true;

  d = size (obj);
  if (isscalar (obj))
    fprintf ('%s = (%s) ', inputname (1), class (obj));
    fprintf ('%s', obj.text);

    if (display_snippet)
      snippet_of_sympy (obj)
    else
      fprintf ('\n')
    end

  elseif (length (d) == 2)
    %% 2D Array
    [n m] = deal (d(1), d(2));
    fprintf ('%s = (%s %dx%d matrix) ...\n', inputname (1), ...
             class (obj), n, m);

    if (loose), fprintf ('\n'); end

    print_indented (obj.text)

    if (display_snippet)
      snippet_of_sympy (obj)
    else
      fprintf ('\n')
    end

    if (loose), fprintf ('\n'); end

  else
    %% nD Array
    % (not possible with sympy matrix)
    fprintf ('%s = (%s nD array) ...\n', inputname (1), class (obj));
    fprintf ('%s', obj.text);
  end
end

function print_indented(s, n)
  if (nargin == 1)
    n = 3;
  end
  pad = char (double (' ')*ones (1,n));
  fprintf (pad);
  %FIXME: extra sprintf needed on Octave 3.6.4, seems harmless on 3.8.1?
  %s = regexprep (s, '\n', ['\n' pad]);
  s = regexprep (s, '\n', sprintf ('\n%s', pad));
  fprintf ('%s', s);
end


function snippet_of_sympy(obj)
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
  fprintf ('   "%s"\n', s);
end
