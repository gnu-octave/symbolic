function s = sym(x)
%SYM  Symbolic class implemented with sympy
%

  if (nargin == 0)
    s = sym(0);
    return
  end

  if (strcmp (class (x), 'sym'))
    s = x;
  else
    % make the python pickle of the sympy object
    fd = fopen('sym_python_temp.py', 'w');
    fprintf(fd, 'import sympy as sp\nimport pickle\n');
    if (isa (x, 'double'))
      % TODO: maybe cleaner to generate a string and then call the
      % constructor again....
      if (x == pi)
        fprintf(fd, 'z = sp.pi\n');
      elseif (isinf(x)) && (x > 0)
        fprintf(fd, 'z = sp.oo\n');
      elseif (isinf(x)) && (x < 0)
        fprintf(fd, 'z = -sp.oo\n');
      elseif (mod(x,1) == 0)
        % is integer
        fprintf(fd, 'z = sp.Rational("%d")\n', x);
      else
        error('use quoted input for fractions');
        % TODO: matlab allows 1/3 and other "small" fractions, but
        % I don't trust this behaviour anyway.
      end
    elseif (isa (x, 'char'))
      if (strcmp(x, 'pi'))
        fprintf(fd, 'z = sp.pi\n');
      elseif (strcmp(x, 'inf')) || (strcmp(x, '+inf'))
        fprintf(fd, 'z = sp.oo\n');
      elseif (strcmp(x, '-inf'))
        fprintf(fd, 'z = -sp.oo\n');
      else
        xd = str2double(x);
        if (isnan (xd))
          fprintf(fd, 'z = sp.Symbol("%s")\n', x);
        else
          fprintf(fd, 'z = sp.Rational("%d")\n', xd);
        end
      end
    else
      error('conversion from that type to symbolic not (yet) supported');
    end
    fprintf(fd, 'print "__________"\n');
    fprintf(fd, 'print str(z)\n');
    fprintf(fd, 'print "__________"\n');
    fprintf(fd, 'print pickle.dumps(z)\n');
    fclose(fd);
    [status, out] = system('python sym_python_temp.py');
    if status ~= 0
      error('failed');
    end
    A = regexp(out, '__________\n(.*)\n__________\n(.*)', 'tokens');
    s.text = A{1}{1};
    s.pickle = A{1}{2};
    s = class(s, 'sym');
  end