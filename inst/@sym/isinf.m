function r = isinf(x)
%ISINF   Is symbolic infinity?

  if isscalar(x)

    cmd = [ 'd = _ins[0].is_finite\n'  ...
            'if (d==True):\n'                ...
            '    return (False,)\n'           ...
            'elif (d==False):\n'             ...
            '    return (True,)\n'          ...
            'else:\n'                        ...
            '    return (False,)' ];

    r = python_cmd (cmd, x);

    if (~ islogical(r))
      error('nonboolean return from python');
    end

  else  % array
    r = logical(zeros(size(x)));
    for j = 1:numel(x)
      % Bug #17
      idx.type = '()';
      idx.subs = {j};
      r(j) = isinf(subsref(x, idx));
    end
  end
