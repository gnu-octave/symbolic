Octave-Symbolic-SymPy
=====================

An implementation of a symbolic toolbox using SymPy.


Goals
-----

Feature parity with the other symbolic toolboxes.



Implementation
--------------

Generate Python code to do the actual work.  Sym objects keep a text
field for display purposes and a "pickle" (string) of their python
object.  The objects are communicated between Python and Octave by
passing the pickles back-and-forth.  Currently pure m-file (and
Python) implementation.



Communication
-------------

Currently, we open a new Python process for each operation.  This
could surely be improved.



