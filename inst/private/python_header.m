function s = python_header()
%private

  if (1 == 0)
    %s = sprintf('import sympy as sp\nimport pickle\n\n');
    s = python_header_embed();
    return


  else
    % for debugging/development
    %s = fileread('python_header.py');
    [f,msg] = fopen('private/python_header.py');
    if (f == -1)
      error(['Error reading python header: ' msg])
    end
    A = '';
    while(1)
      s = fgets (f);
      if (ischar (s))
        A = [A s];
      else
        break
      end
    end
    fclose(f);
    s = A;
    return
  end
end
