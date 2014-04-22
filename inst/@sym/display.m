function display(obj)
%DISPLAY  Display contents of a symbolic expression

%   Note: if you edit this, make sure you edit disp.m as well

  %% Settings
  unicode_decorations = true;
  display_snippet = octsympy_config('snippet');
  loose = strcmp(get(0,'FormatSpacing'), 'loose');

  d = size (obj);
  if (isscalar (obj))
    fprintf ('%s = (%s)', inputname (1), class (obj))
    fprintf (' %s', obj.flattext)

    if (display_snippet)
      fprintf ('     ')
      snippet_of_sympy (obj, unicode_decorations)
    else
      fprintf ('\n')
    end

  elseif (length (d) == 2)
    %% 2D Array
    if (unicode_decorations)
      formatstr = '%s = (%s %d×%d matrix)';
    else
      formatstr = '%s = (%s %dx%d matrix)';
    end
    fprintf (formatstr, inputname (1), class (obj), d(1), d(2))

    if (display_snippet)
      fprintf ('        ')
      snippet_of_sympy (obj, unicode_decorations)
    else
      fprintf ('\n')
    end

    if (loose), fprintf ('\n'); end

    print_indented (obj.text)

    if (loose), fprintf ('\n'); end

  else
    %% nD Array
    % (not possible with sympy matrix)
    fprintf ('%s = (%s nD array) ...\n', inputname (1), class (obj))
    fprintf ('%s', obj.text)
  end
end

function print_indented(s, n)
  if (nargin == 1)
    n = 3;
  end
  pad = char (double (' ')*ones (1,n));
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
  disp(s)
end


function snippet_of_sympy(obj, unicode_decorations)

  if (unicode_decorations)
    ell = '…';
    lquot = '“'; rquot = '”';
  else
    ell = '...';
    lquot = '"'; rquot = lq;
  end
  % trim newlines (if there are any)
  %s = regexprep (obj.pickle, '\n', '\\n');
  s = regexprep (obj.pickle, '\n', '\');
  len = length (s);
  if len > 42
    s = [s(1:42) ell];
  end
  fprintf ([lquot '%s' rquot '\n'], s);
end
