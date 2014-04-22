function varargout = pretty(x)
%PRETTY   ascii-art/unicode of a symbolic expression
%
%   Note: pretty(x) works like disp(x) (makes output even if has a
%   semicolon)
%
%   todo: use_unicode as a global var?, use_unicode=False)
%   todo: wrapping column?
%

  loose = strcmp(get(0,'FormatSpacing'), 'loose');

  cmd = [ 'd = sp.pretty(*_ins, use_unicode=True)\n'  ...
          'return (d,)' ];

  s = python_cmd (cmd, x);

  if (nargout == 0)
    if (loose), fprintf ('\n'); end
    print_indented (s)
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
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
  disp(s)
end
