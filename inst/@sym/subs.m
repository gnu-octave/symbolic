%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{g} =} subs (@var{f}, @var{x}, @var{y})
%% Replace symbols in an expression with other expressions.
%%
%% Example replacing x with y.
%% @example
%% f = x*y;
%% subs(f, x, y)
%% @end example
%%
%% @example
%% subs(f, x, sin(x))
%% subs(f, @{x y@}, @{sin(x) 16@})
%%
%% F = [x x*y; 2*x*y y];
%% subs(F, @{x y@}, @{2 sym(pi)@})
%% subs(F, @{x y@}, [2 sym(pi)])
%% subs(F, [x y], [2 sym(pi)])
%% subs(F, [x y], @{2 sym(pi)@})
%% @end example
%%
%% @seealso{symfun}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, substitution


function g = subs(f, in, out)

  %% Simple code for scalar x
  % The more general code would work fine, but maybe this makes some
  % debugging easier, e.g., without simultaneous mode?
  if (isscalar(in) && ~iscell(in) && ~iscell(out))
    cmd = [ '(f,x,y) = _ins\n'  ...
            'return (f.subs(x,y),)' ];
    g = python_cmd (cmd, sym(f), sym(in), sym(out));
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
      % not really Bug #17, but I doubt if I'd have done it this
      % way w/o that bug.
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

  cmd = [ '(f,sublist) = _ins\n'  ...
          'g = f.subs(sublist, simultaneous=True)\n'  ...
          'return (g,)' ];

  g = python_cmd (cmd, sym(f), sublist);
