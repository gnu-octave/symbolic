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
