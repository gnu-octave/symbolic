function r = undo_highbyte_escapes(s)
%UNDO_HIGHBYTE_ESCAPES   Convert non-ascii characters into \x escapes
%   Suppose we have a unicode string such as
%   >> s = '⌈y⌉'
%   s = ⌈y⌉
%   >> double(s)
%   ans =   226   140   136   121   226   140   137
%
%
%   We can escape the highbytes as in:
%   >> r = undo_highbyte_escapes(s)
%   r = \xe2\x8c\x88y\xe2\x8c\x89
%
%
%   FIXME: do a vectorized implementation, or at least skip
%   continuous chunks of ascii
%
%   FIXME: probably only works on Octave, not Matlab.
%
%   Copyright 2016-2017 Colin B. Macdonald
%
%   Copying and distribution of this file, with or without modification,
%   are permitted in any medium without royalty provided the copyright
%   notice and this notice are preserved.  This file is offered as-is,
%   without any warranty.

  d = double(s);

  %I = d > 127;

  r = '';
  for j=1:length(d)
    if (d(j) <= 127)
      r = [r s(j)];
    else
      r = [r '\x' tolower(dec2hex(d(j)))];
    end
  end
