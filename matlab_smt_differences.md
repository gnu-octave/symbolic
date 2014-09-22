Differences between OctSymPy and the Symbolic Math Toolbox
==========================================================

The Symbolic Math Toolbox (SMT) is proprietary software sold by The
Mathworks.  We want some minimal compatibility.  This document notes
the differences.



Functions only SMT has
----------------------

> "Uh, all of them, I think."
>     --John Conner, 1995

That is, your help is needed here.



Functions only OctSymPY has
---------------------------

These should be updated to match SMT if/when they are added.

* fibonacci
* isprime
* nextprime



Differences
-----------

* bernoulli in octsympy gives explicit polynomials whereas SMT treats
  e.g., diff() using identities.

* SMT's sym() constructor allows big string expressions: we don't
  really support that (and its not the way modern SMT is used either).
  Build your expressions like sym('x')/2 rather than sym('x/2').

* OctSymPy has [p,m] = factor(a) which returns an array of the
  prime factors and their multiplicities.  Pure Matlab 'factor' has
  this but strangely SMT 'factor' does not.

* Assumptions are quite different, although we fake quite a bit for
  compatibility, see section below.

* SMT has isinf(x + oo) and isinf(x*oo) true.  SymPy says false.

* SMT logical(sym('x')), logical(sym(pi)) are errors.  OctSymPy has true (b/c nonzero).  FIXME: double-check later

* SMT char(expr) outputs MuPAD code string; OctSymPy outputs SymPy string.


Differences in assumptions
--------------------------

In OctSymPy, if you create a symbol with assumptions,
those stay with any expressions and are not "updated" if you introduce a new symbol with the same expression.  For example:

````
syms x positive
x2 = sym('x', 'real')
isequal(x,x2)   % false
````
or
````
x = sym('x', 'positive')
eqn = x^2 == 4
solve(eqn)  % 2
x = sym('x')
solve(eqn)   % still 2, eqn has the old symbol
solve(eqn,x)  % empty: the variable in x is not the same as that in eqn.
````

Other notes:

* SMT assumptions seem to be stored centrally: FIXME: double check
  that SMT functions do have their own assumptions workspace.

* assume(), assumeAlso(), sym('x', 'clear'), "syms x clear".
  All of these muck around in the caller's workspace, traversing
  sym, struct and cell arrays to replace x with the new x.

* in both OctSymPy and SMT, you can add assumptions when
  creating a sym as in sym('x', 'real') and sym('x', 'positive').
  OctSymPy also supports others including 'integer', 'even', 'odd'.
