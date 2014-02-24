function syms(varargin)
  nargin
  for i = 1:nargin
    cmd = sprintf('%s = sym(''%s'');', varargin{i}, varargin{i});
    disp(['evaluating command: ' cmd])
    evalin('caller', cmd)
  end
  %varargin

