function g = subs(f, in, out)
%SUBS   replace symbols in an expression with other expressions
%   f = x*y;
%   subs(f, x, y)
%      replaces x with y.
%
%   subs(f, x, sin(x))
%
%   subs(f, {x y}, {sin(x) 16})
%
%   F = [x x*y; 2*x*y y];
%   subs(F, {x y}, {2 sym(pi)})
%

  %% Simple code for scalar x
  % The more general code would work fine, but maybe this makes some
  % debugging easier, e.g., without simultaneous mode?
  if (isscalar(in) && ~iscell(in) && ~iscell(out))
    cmd = [ 'def fcn(_ins):\n'       ...
            '    (f,x,y) = _ins\n'   ...
            '    g = f.subs(x,y)\n'  ...
            '    return (g,)\n' ];
    g = python_sympy_cmd(cmd, sym(f), sym(in), sym(out));
    return
  end


  %% In general
  % We build a list of of pairs of substitutions.

  %in = sym(in);      % no, might be cell arrays
  %out = sym(out);


  if (iscell(in))   % cell input, any size
    assert_same_shape(in,out)
    assert(iscell(out))   % Actually, SMT allows mix of array and cell
    sublist = cell(1, numel(in));
    for i = 1:numel(in)
      sublist{i} = {sym(in{i}), sym(out{i})};
    end

  elseif (numel(in) >= 2)  % array input, non scalar
    % Note: annoyingly similar ways to build sublist but I counldn't
    % make it work with just one.
    assert_same_shape(in,out)
    assert(~iscell(out))
    sublist = cell(1, numel(in));
    for i = 1:numel(in)
      idx.type = '()';
      idx.subs = {i};
      sublist{i} = {sym(subsref(in, idx)), sym(subsref(out, idx))};
    end

  elseif (numel(in) == 1)  % scalar, non-cell input
    assert(~iscell(out))
    % out could be an array (although this doesn't work b/c of
    % Issue #10)
    sublist = {{sym(in), sym(out)}};

  else
    error('not a valid sort of subs input (?)');
  end

  % simultaneous=True is important so we can do subs(f,[x y], [y x])

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (f,sublist) = _ins\n'  ...
          '    #sys.stderr.write("pydebug: f: " + str(f) + "\\n")\n' ...
          '    #sys.stderr.write("pydebug: in: " + str(sublist) + "\\n")\n' ...
          '    g = f.subs(sublist, simultaneous=True)\n'  ...
          '    return (g,)\n' ];

  g = python_sympy_cmd(cmd, sym(f), sublist);
