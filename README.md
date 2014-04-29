OctSymPy
========

An implementation of a symbolic toolbox using SymPy.



Goals
-----

Feature parity with the other symbolic toolboxes.

![ScreenShot](/screenshot.png)


Status
------

"Alpha" quality at best!  Contributions welcome.



How to Install
--------------

1. The only dependencies are Python and SymPy.  Consult the SymPy
website (e.g., "yum install sympy" on Fedora)

2. Download the latest release, e.g., octsympy-0.0.3.tar.gz

3. Run Octave in the folder containing the octsympy-0.0.3.tar.gz file.

4. At Octave prompt, type "pkg install octsympy-0.0.03.tar.gz".

5. At Octave prompt, type "pkg load octsympy".

6. At Octave prompt, type "syms x", then "(sin(x/2))^3".



Implementation
--------------

Generate Python code to do the actual work.  Sym objects keep a text
field for display purposes and a string (currently an SymPy ``srepr'')
of their python object.  The objects are communicated between Python
and Octave by passing the srepr's back-and-forth.  Currently pure
m-file (and Python) implementation, no code to be compiled.


Communication
-------------

We have two IPC mechanisms between Octave and Python.  One option is
calling "system()".  The other uses "popen2()".  Others could be
implemented.



Related Projects
----------------

* The Octave-Forge symbolic toolbox [http://octave.sourceforge.net/symbolic/index.html].  My impression is the VPA is pretty good.

* "SymPy CAS" by Jonathan Lister [http://www.mathworks.com/matlabcentral/fileexchange/42787-sympy-cas-in-matlab].  Calls SymPy commands using calls to system().

