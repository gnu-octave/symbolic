function A = extractblock(out)

  sbtag='<output_block>';
  stag='<output_item>';
  etag='</output_item>';
  ebtag='</output_block>';

  try
    s = strfind(out, stag);
    e = strfind(out, etag);
    % detect length of newline (1 on unix, 2 on windows?)
    lnl = e(1)-s(1)-length(stag);
    A = {};
    for i = 1:(length(s)-1)
      A{i} = out( (s(i+1)+length(stag)+lnl) : (e(i+1)-1-lnl) );
    end
  catch
    error('failed to extract output')
    status, out, s, e, A
  end
