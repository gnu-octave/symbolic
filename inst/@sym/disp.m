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
  newl = sprintf('\n');
  s = strrep (s, newl, [newl pad]);
  s = [pad s];  % first line
end
