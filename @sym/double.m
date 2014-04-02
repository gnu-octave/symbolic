function y = double(x, failerr)
%DOUBLE   Convert symbolic to doubles

  if (nargin == 1)
    failerr = true;
  end

  cmd = [ 'def fcn(ins):\n'  ...
          '    (x,) = ins\n'  ...
          '    y = sp.N(x,30)\n'  ...
          '    return (y,)\n' ];
  A = python_sympy_cmd_raw(cmd, x);

  % workaround for Octave 3.6.4 where str2double borks on "inf"
  % instead of "Inf".
  % http://hg.savannah.gnu.org/hgweb/octave/rev/a08f6e17336e
  %if (is_octave())
  if exist('octave_config_info', 'builtin');
    if (compare_versions (OCTAVE_VERSION (), '3.8.0', '<'))
      A{1} = strrep(A{1}, 'inf', 'Inf');
    end
  end

  % special case for nan so we can later detect if str2double finds a double
  if (strcmp(A{1}, 'nan'))
    y = NaN;
    return
  end

  % special case for zoo which at least sympy 0.7.4
  if (strcmp(A{1}, 'zoo'))
    y = Inf;
    return
  end
  y = str2double (A{1});
  if (isnan (y))
    y = [];
    if (failerr)
      error('Failed to convert %s ''%s'' to double', class(x), x.text);
    end
  end

