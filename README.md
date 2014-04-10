Octave-Symbolic-SymPy
=====================

An implementation of a symbolic toolbox using SymPy.


Goals
-----

Feature parity with the other symbolic toolboxes.


Status
------

"Alpha" quality at best!  Contributions welcome.


Implementation
--------------

Generate Python code to do the actual work.  Sym objects keep a text
field for display purposes and a "pickle" (string) of their python
object.  The objects are communicated between Python and Octave by
passing the pickles back-and-forth.  Currently pure m-file (and
Python) implementation.



Communication
-------------

We have two IPC mechanisms between Octave and Python.  One option is
calling "system()".  The other uses "popen2()".


Related Projects
----------------

* The Octave-Forge symbolic toolbox [http://octave.sourceforge.net/symbolic/index.html].  VPA is pretty good.

* "SymPy CAS" by Jonathan Lister [http://www.mathworks.com/matlabcentral/fileexchange/42787-sympy-cas-in-matlab].  Calls SymPy commands using calls to system().

