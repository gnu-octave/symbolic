function r = do_highbyte_escapes(s)
%DO_HIGHBYTE_ESCAPES  Convert "\x"-escaped strings to bytes
%   Convert sequences strings of the form '\xNM' into characters.
%   Here NM is a two-char hex string.  Typically sequences of these
%   represent utf-8 characters.
%
%   Example:
%   >> s = 'a\xe2\x8c\x88y\xe2\x8c\x89b';
%   >> do_highbyte_escapes(s)
%      ans = a⌈y⌉b
%

  I = strfind(s, '\x');
  % new string with X instead of escapes
  r = regexprep(s, '\\x(..)',  'X');

  % list of 2 digit hex numbers
  s2 = s([I'+2 I'+3]);
  % slowest part on Octave
  dec = char(hex2dec(s2));

  % positions of escaped bytes in the new string r
  I = I - [0:4:(4*length(I)-1)] + [0:(length(I)-1)];
  r(I) = dec;

  if (~ exist ('octave_config_info', 'builtin'))
    % matlab is not UTF-8 internally
    r = native2unicode(uint8(r));
  end

end
