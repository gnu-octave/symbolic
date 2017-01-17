function out = subsasgn (val, idx, rhs)

  switch idx.type
    case '()'
      %% symfun constructor
      % f(x) = rhs
      %   f is val
      %   x is idx.subs{1}
      % This also gets called for "syms f(x)"

      all_syms = true;
      for i = 1:length(idx.subs)
        all_syms = all_syms && isa(idx.subs{i}, 'sym');
      end
      if (all_syms)
        cmd = { 'L, = _ins'
                'return all([x is not None and x.is_Symbol for x in L])' };
        all_Symbols = python_cmd (cmd, idx.subs);
      end
      if (all_syms && all_Symbols)
	%% Make a symfun
        if (~isa(rhs, 'sym'))
          % rhs is, e.g., a double, then we call the constructor
          rhs = sym(rhs);
        end
        out = symfun(rhs, idx.subs);

      else
        %% Not symfun: e.g., f(double) = ..., f(sym(2)) = ...,
        % convert any sym subs to double and do array assign
        for i = 1:length(idx.subs)
          if (isa(idx.subs{i}, 'sym'))
            idx.subs{i} = double(idx.subs{i});
          end
        end
	for i = 1:length(idx.subs)
          if (~ sym.is_valid_index (idx.subs{i}))
            error('OctSymPy:subsref:invalidIndices', ...
                  'invalid indices: should be integers or boolean');
          end
	end
        out = sym.mat_replace (val, idx.subs, sym(rhs));
      end
      
      disp('constructor called!');

    case '.'
      
      val.(idx.subs) = rhs;
      out = val;

    otherwise
      disp('FIXME: do we need to support any other forms of subscripted assignment?')
      idx
      rhs
      val
      error('broken');
  end
end