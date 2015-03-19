function n = ustr_length(str)
%USTR_LENGTH  Return the length of a unicode string
%   Return the number of characters in a string 'str' in a way that
%   works on both Matlab and Octave.  On Matlab this is the same as
%   'length(str)' (FIXME: is that so even for high code plane
%   characters?).  But in Octave, char objects (strings) use UTF-8 and
%   so non-ascii characters uses up to 4 bytes.
%
%   Note: nothing very sophisiticated happens here: there may be
%   things that could not be considered characters that are
%   nonetheless counted towards the length.  In particular: I'm not
%   sure of the relationship between the amount of (monospaced) space
%   taken by a string and the results of this function.

  if ~exist('octave_config_info', 'builtin')
    n = length(str);
    return
  end

  d = double(str)';
  N = length(d);
  b = dec2bin(d, 8);

  % "Bit patterns 0xxxxxxx and 11xxxxxx are synchronizing words used to
  % mark the beginning of the next valid character."  Wikipedia UTF-8.
  ascii = (b(:,1) == '0');  % detect 0xxxxxxx
  target = repmat('11', N, 1);
  multibyte = all(b(:,1:2) == target, 2);  % detect 11xxxxxx

  % Debugging:
  %sp = repmat('  ', N, 1);
  %[num2str(d,'%3d')  sp  b  sp  num2str(ascii)  sp  num2str(multibyte)]

  n = nnz(ascii) + nnz(multibyte);

end


%!assert (isequal (ustr_length('...'), 3))
%!assert (isequal (ustr_length('€'), 1))
%!assert (isequal (ustr_length('ab€c'), 4))
%!assert (isequal (ustr_length('ab€€'), 4))
%!assert (isequal (ustr_length('我爱你 爱着你 就像老鼠爱大米'), 15))
