function r = do_highbyte_escapes(s)
%DO_HIGHBYTE_ESCAPES  Convert "\x"-escaped strings to bytes
%   Convert sequences strings of the form '\xNM' into characters.
%   Here NM is a two-char hex string.  Typically sequences of these
%   represent utf-8 characters.
%
%   Example:
%   >> s = 'aaa\xe2\x8c\x88bbb\xe2\x8c\x89ccc';
%   >> do_highbyte_escapes(s)
%      ans = aaa⌈bbb⌉ccc
%
%
%   But be careful for escaped backslashes that happen to be followed
%   by an 'x'; substrings with an even number of backspaces such as
%   '\\x' or '\\\\x' should not be converted.  Examples:
%   >> s = 'aaa \xe2\x8c\x88 bbb \\xe2\\x8c\\\\x89 ccc';
%   >> do_highbyte_escapes(s)
%      ans = aaa ⌈ bbb \\xe2\\x8c\\\\x89 ccc
%
%   >> s = 'aaa \\\xe2\x8c\x88 bbb';
%   >> do_highbyte_escapes(s)
%      ans = aaa \\⌈ bbb
%
%
%   Copyright 2016-2017 Colin B. Macdonald
%
%   Copying and distribution of this file, with or without modification,
%   are permitted in any medium without royalty provided the copyright
%   notice and this notice are preserved.  This file is offered as-is,
%   without any warranty.


  % pad the string with one char in case string starts with \x
  s = ['_' s];
  i = 2;  % start at 2 b/c of this padding

  [TE, NM] = regexp(s, '(?<=[^\\])(?:\\\\)*\\x(?<hex>..)', 'tokenExtents', 'names');
  %                      1.  2.    3.          4.
  % explanation:
  % 1. look behind ...
  % 2. ... for anything that isn't '\'
  % 3. zero or more pairs '\\'
  % 4. two chars as a named token

  if (isempty(TE))
    r = s(i:end);
    return
  end

  % get the two-char hex numbers make them into bytes
  if (exist ('OCTAVE_VERSION', 'builtin') && ...
      compare_versions (OCTAVE_VERSION (), '4.3.0', '<'))
    % Bug on old Octave: https://savannah.gnu.org/bugs/?49659
    dec = char(hex2dec(NM.hex));
  else
    % roughly 3-4 times slower than the above
    dec = char (hex2dec (struct2cell (NM)));
  end
  % faster:
  %d = uint8('ee');
  %d = (d >= 48 & d <= 57).*(d-48) + (d >= 97 & d <= 102).*(d-87);
  %d = 16*d(1) + d(2);

  % Yep, its a loop :(  Takes about 0.02s for a string of length 1179
  % containing 291 escaped unicode chars.  Roughly 6 times slower than
  % the hex2dec bit above.
  r = '';
  for j=1:length(TE)
    r = [r s(i:TE{j}(1)-3) dec(j)];
    i = TE{j}(2)+1;
  end
  r = [r s(i:end)];

  if (~ exist ('OCTAVE_VERSION', 'builtin'))
    % matlab is not UTF-8 internally
    r = native2unicode(uint8(r));
  end

end
