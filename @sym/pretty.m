function varargout = pretty(x)
%PRETTY   ascii-art/unicode of an expression
%   todo: use_unicode as a global var?, use_unicode=False)
%   todo: wrapping column?

  % FIXME: how to access format compact/loose setting?
  loose = true;

  cmd = [ 'def fcn(_ins):\n'  ...
          '    d = sp.pretty(*_ins, use_unicode=True)\n'  ...
          '    return (d,)\n' ];

  s = python_sympy_cmd (cmd, x);

  if (nargout == 0)
    if (loose), fprintf ('\n'); end
    print_indented (s)
    fprintf ('\n');
    if (loose), fprintf ('\n'); end
  else
    varargout = {s};
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
