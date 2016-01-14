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
%
%   TODO: faster (vectorized) implementation is surely possible.

  st = tic();
  [S, E, TE, M, T, NM, SP] = regexp(s, '\\x(..)');
  t1 = toc(st);

  st = tic;
  i = 1;
  r = '';
  for j=1:length(S)
    d = hex2dec(T{j}{1});
    r = [r s(i:S(j)-1) char(d)];
    i = E(j)+1;
  end
  r = [r s(i:end)];
  t2 = toc(st);
  disp(sprintf('time=[%g %g], r=%s', t1, t2, r))
