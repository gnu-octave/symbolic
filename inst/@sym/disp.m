function varargout = disp(obj)
%DISP   Display the value of a symbolic expression

%   Note: if you edit this, make sure you edit display.m as well

  if (isscalar (obj))
    s = obj.flattext;
  else
    s = obj.text;
  end
  s = make_indented(s);

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end
end


function s = make_indented(s, n)
  if (nargin == 1)
    n = 3;
  end
  pad = char (double (' ')*ones (1,n));

  s2 = pad;
  %FIXME: extra sprintf needed on Octave 3.6.4, seems harmless on 3.8.1?
  %s = regexprep (s, '\n', ['\n' pad]);
  s = regexprep (s, '\n', sprintf ('\n%s', pad));
  s = [pad s];
end
