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
%   subs(F, {x y}, [2 sym(pi)])
%   subs(F, [x y], [2 sym(pi)])
%   subs(F, [x y], {2 sym(pi)})

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

  in = sym(in);
  out = sym(out);



  if ( (iscell(in))  ||  (numel(in) >= 2) )
    assert_same_shape(in,out)
    sublist = cell(1, numel(in));
    for i = 1:numel(in)
      if (iscell(in)),  idx1.type = '{}'; else idx1.type = '()'; end
      if (iscell(out)), idx2.type = '{}'; else idx2.type = '()'; end
      idx1.subs = {i};
      idx2.subs = {i};
      sublist{i} = { subsref(in, idx1), subsref(out, idx2) };
    end

  elseif (numel(in) == 1)  % scalar, non-cell input
    assert(~iscell(out))
    % out could be an array (although this doesn't work b/c of
    % Issue #10)
    sublist = { {in, out} };

  else
    error('not a valid sort of subs input');
  end

  % simultaneous=True is important so we can do subs(f,[x y], [y x])

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (f,sublist) = _ins\n'  ...
          '    #sys.stderr.write("pydebug: f: " + str(f) + "\\n")\n' ...
          '    #sys.stderr.write("pydebug: in: " + str(sublist) + "\\n")\n' ...
          '    g = f.subs(sublist, simultaneous=True)\n'  ...
          '    return (g,)\n' ];

  g = python_sympy_cmd(cmd, sym(f), sublist);
