function t = isequaln(x,y,varargin)
%ISEQUALN   Test if two symbolic arrays are same
%   Here nan == nan is true, see also isequal where nan != nan.
%
%   See also == (eq), logical and isAlways


  %% some special cases
  if ~(is_same_shape(x,y))
    t = false;
    return
  end

  % at least on sympy 0.7.4, 0.7.5, nan == nan is true so we
  % don't need to detect it ourselves (todo: this seems a bit
  % fragile to rely on!)

  % sympy's == is not componentwise so no special case for arrays

  cmd = [ 'def fcn(_ins):\n'  ...
          '    d = _ins[0] == _ins[1]\n'  ...
          '    return (d,)\n' ];

  t = python_sympy_cmd (cmd, sym(x), sym(y));

  if (~ islogical(t))
    error('nonboolean return from python');
  end

  %else  % both are arrays
  %  t = logical(zeros(size(x)));
  %  for j = 1:numel(x)
  %    % Bug #17
  %    idx.type = '()';
  %    idx.subs = {j};
  %    t(j) = isequaln(subsref(x,idx),subsref(y,idx));
  %  end
  %end

  if (nargin >= 3)
    t = t & isequaln(x, varargin{:});
  end
