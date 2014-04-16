function r = isnan(x)
%ISNAN   Is symbolic expression Not-a-Number?

  % todo: neat idea but fails for matrices
  %r = isnan (double (x, false));

  if isscalar(x)

    cmd = [ 'def fcn(_ins):\n'              ...
            '    d = _ins[0] == sp.nan\n'  ...
            '    return (d,)\n' ];

    r = python_sympy_cmd (cmd, x);

    if (~ islogical(r))
      error('nonboolean return from python');
    end

  else  % array
    r = logical(zeros(size(x)));
    for j = 1:numel(x)
      % Bug #17
      idx.type = '()';
      idx.subs = {j};
      r(j) = isnan(subsref(x, idx));
    end
  end
