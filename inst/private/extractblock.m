function A = extractblock(out, tagitem, tagenditem)
%private function

  try
    s = strfind(out, tagitem);
    e = strfind(out, tagenditem);
    % detect length of newline (1 on unix, 2 on windows?)
    lnl = e(1)-s(1)-length(tagitem);
    A = {};
    for i = 1:(length(s)-1)
      A{i} = out( (s(i+1)+length(tagitem)+lnl) : (e(i+1)-1-lnl) );
    end
  catch
    error('failed to extract output')
    status, out, s, e, A
  end
