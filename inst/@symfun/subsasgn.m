%% Copyright (C) 2017 Abhinav Tripathi
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypeop  Method   @@sym {@var{f} =} subsasgn (@var{f}, @var{idx}, @var{rhs})
%% @deftypeopx Operator @@sym {} {@var{f}(@var{i}) = @var{rhs}} {}
%% @deftypeopx Operator @@sym {} {@var{f}(@var{i}, @var{j}) = @var{rhs}} {}
%% @deftypeopx Operator @@sym {} {@var{f}(@var{i}:@var{j}) = @var{rhs}} {}
%% @deftypeopx Operator @@sym {} {@var{f}(@var{x}) = @var{symexpr}} {}
%% Assign value to a symbolic function [constructor].
%%
%% @end deftypeop

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
      end

    case '.'
      assert (isa (rhs, 'symfun'))
      assert (~ isa (idx.subs, 'symfun'))
      assert (~ isa (val, 'symfun'))
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


%!test
%! syms x;
%! f(x) = x^2;
%! assert (isa (f, 'symfun'))
