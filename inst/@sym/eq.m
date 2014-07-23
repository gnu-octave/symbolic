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
%% @deftypefn {Function File} {@var{g} =} eq (@var{a}, @var{b})
%% Test for symbolic equality, and/or define equation.
%%
%% @code{a == b} tries to convert both @code{a} and @code{b} to
%% numbers and compare them as doubles.  If this fails, it defines
%% a symbolic expression for @code{a == b}.  When each happens is a
%% potential source of bugs!
%%
%% FIXME: Notes from SMT:
%% @itemize
%% @item If any varibles appear in the matrix, then you get a matrix
%%   of equalities:  syms x; a = sym([1 2; 3 x]); a == 1
%% @item @code{x==x} is an equality, rather than @code{true}.
%%   We currently satisfy neither of these (FIXME).
%% @end itemize
%%
%% FIXME: from reading SymPy's @code{Eq??}, the following would
%% seem to work:
%%    @code{>>> e = relational.Relational.__new__(relational.Eq, x, x)}
%% (but passing this to solve() is still different from SMT).
%%
%% FIXME: array case is hardcoded only to check for equality (see logical()).
%%   to get the SMT, could do two passes through the array.
%%
%% @seealso{logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function t = eq(x,y)

  if isscalar(x) && isscalar(y)

    % Note: sympy 0.7.4 Eq() returns python native bools,
    % but in 0.7.5 it has its own bool type.  Hence the d==True
    % stuff below

    % FIXME: we could hack around the SymPy NaN Eq behaviour, see Bug #9

    cmd = [ '#dbout(_ins)\n'                 ...
            'd = sp.Eq(_ins[0], _ins[1])\n'  ...
            '#dbout(d)\n'                    ...
            'if (d==True):\n'                ...
            '    return (True,)\n'           ...
            'elif (d==False):\n'             ...
            '    return (False,)\n'          ...
            'else:\n'                        ...
            '    return (d,)' ];

    % note: t could be bool or sym here
    t = python_cmd (cmd, sym(x), sym(y));


  elseif isscalar(x) && ~isscalar(y)
    %disp('eq matrix to scalar')
    t = logical(zeros(size(y)));
    for j = 1:numel(y)
      % Bug #17
      %t(j) = logical(x == y(j));
      idx.type = '()';
      idx.subs = {j};
      t(j) = logical(x == subsref(y, idx));
    end


  elseif ~isscalar(x) && isscalar(y)
    t = (y == x);


  else  % both are arrays
    % bug? for some reason, can't use () here, wtf?
    %x(1)
    assert_same_shape(x,y);
    %disp('eq two arrays: after assert')
    t = logical(zeros(size(x)));
    for j = 1:numel(x)
      % Bug #17, the original
      %t(j) = logical(x(j) == y(j));   % wtf!
      idx.type = '()';
      idx.subs = {j};
      t(j) = logical(subsref(x,idx) == subsref(y,idx));
    end
  end
  return


    % see comments above
    for j = 1:numel(x)
      temp = (x(j) == y(j));
      if (isbool(temp))
        if temp
          t(j) = 1;
        else
          t(j) = 0;
        end
      else
        t(j) = temp;
      end
    end

end


%!xtest
%! % known failure, issue #55; an upstream issue
%! snan = sym(nan);
%! assert(~(snan == snan))
