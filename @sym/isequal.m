function t = isequal(x,y,varargin)
%ISEQUAL   Test if two symbolic arrays are same
%   Here nan's are considered nonequal, see also isequaln where nan == nan.
%
%   See also == (eq), logical and isAlways

  if (any(isnan(x)))
    % at least on sympy 0.7.4, 0.7.5, nan == nan is true so we
    % detect is ourselves
    t = false;
  else
    t = isequaln(x,y,varargin{:});
  end
