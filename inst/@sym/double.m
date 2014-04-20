function y = double(x, failerr)
%DOUBLE   Convert symbolic to doubles
%   Convert a sym x to double:
%      y = double(x)
%   If conversion fails, you get an error.
%
%   You can pass an optional "false" to return an empty array if
%   conversion fails on any component.
%      syms x
%      a = [1 2 x];
%      b = double(a, false)
%      isempty(b)

  if (nargin == 1)
    failerr = true;
  end

  if ~(isscalar(x))
    % sympy N() works fine on matrices but it gives objects like "Matrix([[1.0,2.0]])"
    y = zeros(size(x));
    for j = 1:numel(x)
      % Bug #17
      idx.type = '()';
      idx.subs = {j};
      temp = double(subsref(x,idx), failerr);
      if (isempty(temp))
        y = [];
        return
      end
      y(j) = temp;
    end
    return
  end

  % FIXME: maybe its better to do the special casing, etc on the
  % python end?  Revisit this when fixing proper movement of
  % doubles (Bug #11).

  cmd = [ '(x,) = _ins\n'  ...
          'y = sp.N(x,20)\n'  ...
          'y = str(y)\n'  ...
          'return (y,)' ];

  A = python_cmd (cmd, x);
  assert(ischar(A))

  % workaround for Octave 3.6.4 where str2double borks on "inf"
  % instead of "Inf".
  % http://hg.savannah.gnu.org/hgweb/octave/rev/a08f6e17336e
  %if (is_octave())
  if exist('octave_config_info', 'builtin');
    if (compare_versions (OCTAVE_VERSION (), '3.8.0', '<'))
      A = strrep(A, 'inf', 'Inf');
    end
  end

  % special case for nan so we can later detect if str2double finds a double
  if (strcmp(A, 'nan'))
    y = NaN;
    return
  end

  % special case for zoo, at least in sympy 0.7.4, 0.7.5
  if (strcmp(A, 'zoo'))
    y = Inf;
    return
  end

  y = str2double (A);
  if (isnan (y))
    y = [];
    if (failerr)
      error('Failed to convert %s ''%s'' to double', class(x), x.text);
    end
  end
