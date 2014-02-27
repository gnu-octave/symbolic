function s = sym(x)
%SYM  Symbolic class implemented with sympy
%

  if (nargin == 0)
    s = sym(0);
    return
  end

  if (strcmp (class (x), 'sym'))
    s = x;
    return
  end


  if (isa (x, 'double'))
    % TODO: maybe cleaner to generate a string and then call the
    % constructor again....
    if (x == pi)
      cmd = 'z = sp.pi\n';
    elseif (isinf(x)) && (x > 0)
      cmd = 'z = sp.oo\n';
    elseif (isinf(x)) && (x < 0)
      cmd = 'z = -sp.oo\n';
    elseif (mod(x,1) == 0)
      % is integer
      cmd = sprintf('z = sp.Rational("%d")\n', x);
    else
      error('use quoted input for fractions');
      % TODO: matlab SMT allows 1/3 and other "small" fractions, but
      % I don't trust this behaviour much.
    end
  elseif (isa (x, 'char'))
    if (strcmp(x, 'pi'))
      cmd = 'z = sp.pi\n';
    elseif (strcmp(x, 'inf')) || (strcmp(x, '+inf'))
      cmd = 'z = sp.oo\n';
    elseif (strcmp(x, '-inf'))
      cmd = 'z = -sp.oo\n';
    else
      if (~isempty((strfind(x, '.'))))
        warning('possible unintended decimal point in constructor string');
      end
      cmd = sprintf('z = sp.S("%s")\n', x);
      %xd = str2double(x);
      %if (isnan (xd))
      %  cmd = sprintf('z = sp.Symbol("%s")\n', x);
      %else
      %  cmd = sprintf('z = sp.Rational("%d")\n', xd);
      %end
    end
  else
    error('conversion from that type to symbolic not (yet) supported');
  end

  fullcmd = [ 'def fcn(ins):\n'  ...
              '    ' cmd  ...
              '    return (z,)\n' ];
  A = python_sympy_cmd_raw(fullcmd);
  s.text = A{1};
  s.pickle = A{2};
  s = class(s, 'sym');

