Symbolic Package for GNU Octave
===============================

An implementation of a symbolic toolbox using SymPy.
A lightweight interface that uses SymPy for symbolic math from Octave — suitable for experimenting with symbolic linear algebra, expressions and simple symbolic workflows.


https://octave.sourceforge.io/symbolic

https://github.com/gnu-octave/symbolic



Goals
-----

Feature parity with the other symbolic toolboxes.

Goals
- Provide core symbolic functionality (diff, simplify, solve)
- Maintain clean Python↔Octave communication using SymPy representations
- Improve test coverage and cross-platform install experience


![Screenshot 1](/screenshot.png)

![Screenshot 2](/screenshot-install.png)



How to Install
--------------

1.  The dependencies are Octave, Python, and SymPy.  Consult the SymPy
    website for details on how to install SymPy.

2.  Start Octave.

3.  At Octave prompt type `pkg install -forge symbolic`.

4.  At Octave prompt, type `pkg load symbolic`.

5.  At Octave prompt, type `syms x`, then `f = (sin(x/2))^3`,
    `diff(f, x)`, etc.


How to install on Ubuntu
-------------------------

1.  Install the dependencies with
    `sudo apt install octave python3-sympy`.
2.  Follow steps 2--5 above.


How to Install on Windows
-------------------------

1.  Get [Octave](http://www.octave.org) for Windows.

2.  At the Octave prompt, type `pkg install -forge symbolic`.

3.  At the Octave prompt, type `pkg load symbolic`.

4.  At the Octave prompt, type `syms x`, then `f = (sin(x/2))^3`,
    `diff(f, x)`, etc.

If you encounter any difficulties (even minor ones) please read and
if possible help us improve the
[wiki page on Windows Installation](https://github.com/gnu-octave/symbolic/wiki/Notes-on-Windows-installation).



How to Install on Matlab
------------------------

Although this package is designed for GNU Octave, it will work with
Matlab.  Currently only the slower system()-based communication is
available.

1.  Download the latest release, e.g., `octsympy-matlab-2.7.0.tar.gz`.

2.  Unzip it somewhere and add it to your Matlab Path.

The .m files for Matlab have been reformatted for Matlab comment
conventions, but are otherwise the same as the Octave source.


How to Help
-----------

We have a list of things to work on tagged [help
wanted](https://github.com/gnu-octave/symbolic/issues?q=is:open+is:issue+label:"help+wanted").
Some of these should be quite easy to fix and would be a great way to
get involved.  Come join us!

How to hack on the code:

1.  Clone the repo with git (preferred, but you can use the "Download
    ZIP" instead if you want).

2. Run Octave from the `inst/` directory so that Octave uses the package
   source directly instead of an installed version. For example:

   ```sh
   cd symbolic/inst
   octave




Implementation
--------------

Python code is generated to do the actual work.  Each sym object keeps
a text field for display purposes and a string (a SymPy `srepr`).  The
objects are communicated between Python and Octave by passing the
srepr string back-and-forth.  Currently pure m-file (and Python)
implementation, no code to be compiled.



Related Projects
----------------

  * There was a previous "symbolic" package in Octave Forge based on
    GiNaC.  Its history has now been merged into this project.

  * ["SymPy CAS" by Jonathan Lister](http://www.mathworks.com/matlabcentral/fileexchange/42787-sympy-cas-in-matlab).
    Calls SymPy commands using system().
