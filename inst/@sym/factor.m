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
%% @deftypefn  {Function File}  {@var{g} =} factor (@var{f})
%% @deftypefnx {Function File}  {[@var{p},@var{m}] =} factor (@var{f})
%% Factor a symbolic polynomial or integer.
%%
%% @seealso{expand}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [p,m] = factor(f)

  % FIXME: doc: SMT does not expose vector output?  Strange, given Matlab's
  % factor(double) command!

  if (isempty (findsymbols (f)))
    %% No syms, integer factorization
    if (nargout <= 1)
      if (~isscalar(f))
        error('FIXME: check SMT, allows array input here?')
      end
      % FIXME: this is fragile, even pretty(y) causes it to expand
      % SMT is less fragile.  Can we do something to force
      % evaluate=False to persist here?
      p = python_cmd ('return factorint(_ins[0], visual=True),', f);
    else
      if (~isscalar(f))
        error('vector output factorization only for scalar integers')
      end
      cmd = { 'd = factorint(_ins[0], visual=False)' ...
              'num = len(d.keys())' ...
              'sk = sorted(d.keys())' ...
              'p = sp.Matrix(1, num, sk)' ...
              'm = sp.Matrix(1, num, lambda i,j: d[sk[j]])\\' ...
              'return (p,m)' };
      [p,m] = python_cmd (cmd, f);
    end


  else
    %% symbols, polynomial factorization
    % FIXME; symvar? optional 2nd argument
    cmd = { 'p = factor(_ins[0])' ...
            '#if isinstance(p, sp.ImmutableMatrix):' ...
            '#    p = p.as_mutable()' ...
            'return (p,)' };
    p = python_cmd (cmd, f);
  end
end



%!test
%! % n = 152862;
%! % [p,m] = factor(n);  % only works on Octave, no Matlab as of 2014a
%! n = 330;  % so we use an output without repeated factors
%! p = factor(n); m = ones(size(p));
%! [ps,ms] = factor(sym(n));
%! assert (isequal (p, ps))
%! assert (isequal (m, ms))

%!test
%! n = sym(2)^4*13;
%! [p,m] = factor(n);
%! assert (isequal (p, [2 13]))
%! assert (isequal (m, [4 1]))

%!test syms x
%! assert( logical (factor(x^2 + 6*x + 5) == (x+5)*(x+1)))

%!test
%! syms x
%! f = [ x^4/2 + 5*x^3/12 - x^2/3     x^2 - 1      10];
%! g = [ x^2*(2*x - 1)*(3*x + 4)/12   (x+1)*(x-1)  10];
%! assert (isequal (factor(f), g))

%!test
%! % "fragile form" works
%! A = factor(sym(124));
%! B = strtrim(disp(A, 'flat'));
%! assert (strcmp (B, '2**2*31**1'))
