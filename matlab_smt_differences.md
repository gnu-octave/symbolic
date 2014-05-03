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
  Build your expressions like sym(x)/2 rather than sym('x/2').

* OctSymPy has [p,m] = factor(a) which returns an array of the
  prime factors and their multiplicities.  Matlab 'factor' has
  this but strangely SMT does not.

* Assumptions: In OctSymPy, if you create a symbol with assumptions,
  those stay with any expressions and are not "updated" if you change
  the symbol.

````
x = sym('x', 'positive')
eqn = x^2 == 4
solve(eqn)  % 2
x = sym('x')
solve(eqn)   % still 2, eqn has the old symbol
solve(eqn,x)  % empty: the variable in x is not the same as that in eqn.
````

* Assumptions: in both OctSymPy and SMT, you can add assumptions when
  creating a sym as in sym('x', 'real') and sym('x', 'positive').
  OctSymPy also supports 'integer', 'even', 'odd'.
