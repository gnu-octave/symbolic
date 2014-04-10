function r = isinf(x)
%ISINF   Is symbolic infinity?

  if isscalar(x)
    % todo: this true pickle paradigm overused, deal with bools properly!
    true_pickle = sprintf('I01\n.');
    false_pickle = sprintf('I00\n.');

    cmd = [ 'def fcn(_ins):\n'              ...
            '    d = _ins[0].is_finite\n'  ...
            '    if (d==True):\n'                ...
            '        return (False,)\n'           ...
            '    elif (d==False):\n'             ...
            '        return (True,)\n'          ...
            '    else:\n'                        ...
            '        return (False,)\n' ];

    z = python_sympy_cmd (cmd, x);

    if (strcmp(z.pickle, true_pickle))
      r = true;
    elseif (strcmp(z.pickle, false_pickle))
      r = false;
    else
      error('nonboolean return from python');
    end

  else  % array
    r = logical(zeros(size(x)));
    for j = 1:numel(x)
      idx.type = '()';
      idx.subs = {j};
      r(j) = isinf(subsref(x, idx));
    end
  end
