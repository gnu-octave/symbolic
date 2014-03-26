function syms(varargin)
%SYMS  Create symbolic variables
%   This is a convenience function.  Type
%      syms x y z
%   instead of
%      x = sym('x');
%      y = sym('y');
%      z = sym('z');
%
%   Careful: this code runs evalin(): you should not use it
%   (programmatically) on strings you don't trust.

  % todo, support symfuns via syms y(x)
  for i = 1:nargin
    cmd = sprintf('%s = sym(''%s'');', varargin{i}, varargin{i});
    %disp(['evaluating command: ' cmd])
    evalin('caller', cmd)
  end

