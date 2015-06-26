Differences between OctSymPy and the Symbolic Math Toolbox
==========================================================

The Symbolic Math Toolbox (SMT) is proprietary software sold by The
Mathworks.  We want some minimal compatibility.  This document notes
the differences.



Functions SMT has that OctSymPy does not have
---------------------------------------------

> "Uh, all of them, I think."
>     --John Conner, 1995

That is, your help is needed here.



Functions that OctSymPy has which SMT does not have
---------------------------------------------------

These should be updated to match SMT if/when they are added.

* fibonacci
* isprime
* nextprime
* lhs/rhs
* isconstant/isallconstant



Differences
-----------

  * bernoulli in octsympy gives explicit polynomials whereas SMT treats e.g.,
    diff() using identities.

  * SMT's sym() constructor allows big string expressions: we don't really
    support that (and its not the way modern SMT is used either).  Build your
    expressions like sym('x')/2 rather than sym('x/2').  (If you do want to
    pass long strings, they should be valid Python SymPy `srepr`
    syntax---i.e., you probably don't want to do this!)

  * OctSymPy has [p,m] = factor(a) which returns an array of the prime
    factors and their multiplicities.  Pure Matlab 'factor' has this but
    strangely SMT 'factor' does not.

  * Assumptions are quite different, although we fake quite a bit for
    compatibility, see section below.

  * SMT has isinf(x + oo) and isinf(x*oo) true.  SymPy says false.

  * SMT logical(sym('x')), logical(sym(pi)) are errors.  OctSymPy has true
    (b/c nonzero).  FIXME: double-check later

  * SMT char(expr) outputs MuPAD code string; OctSymPy outputs SymPy string.

  * Suppose we have a symfun `g(s,t) = x`.  Both SMT and OctSymPy
    agree that `symvar(g, 1)` is `s` (i.e., preference for the
    independent variables).  However, `symvar(g)` gives `[s t x]` in
    OctSymPy and `x` in SMT.  I suspect this is an SMT bug.  At any
    rate, its probably better to use `argnames` and `symvar(formula)` if
    these sorts of subtlies are important to you.

  * SMT and OctSymPy differ in how the return solutions to systems of
    equation has multiple solutions.  For example: `d = solve(x*x ==
    4, x == 2*y)` In OctSymPy, the two solutions are `d{1}` and
    `d{2}`.  Components are accessed as `d{1}.x` (the x component of
    the first solution).  In SMT, its the opposite: `d.x` gives the x
    component of both solutions as a column vector.  I prefer our way
    (but this could be changed fairly easily.)

    `[X, Y] = solve(x*x == 4, x == 2*y)` does the same on both, returning
    column vectors for X and Y.

  * SMT sym2poly converts to a double array.  We *currently* copy this
    behaviour but might change in the future.  We recommend
    `double(sym2poly(x^2 + 3))` for clarity and compatibility.  Our
    sym2poly also takes an optional extra argument to specify `x`
    which returns a symbolic row vector.

  * SMT fourier/ifourier/laplace/ilaplace have strange rules for determining
    a transform with respect to what variable.  We just use symvar (that is,
    a preference for `x` over other variables like `t`).


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
