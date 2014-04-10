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

  true_pickle = sprintf('I01\n.');
  false_pickle = sprintf('I00\n.');

  cmd = [ 'def fcn(_ins):\n'  ...
          '    d = _ins[0] == _ins[1]\n'  ...
          '    return (d,)\n' ];

  z = python_sympy_cmd (cmd, sym(x), sym(y));

  if (strcmp(z.pickle, true_pickle))
    t = true;
  elseif (strcmp(z.pickle, false_pickle))
    t = false;
  else
    error('Monsieur! Ce nes pas possible!');
  end

  %else  % both are arrays
  %  t = logical(zeros(size(x)));
  %  for j = 1:numel(x)
  %    idx.type = '()';
  %    idx.subs = {j};
  %    t(j) = isequaln(subsref(x,idx),subsref(y,idx));
  %  end
  %end

  if (nargin >= 3)
    t = t & isequaln(x, varargin{:});
  end
