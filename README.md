Symbolic Package for GNU Octave
===============================

[![Build Status](https://travis-ci.org/cbm755/octsympy.svg?branch=master)](https://travis-ci.org/cbm755/octsympy)

An implementation of a symbolic toolbox using SymPy.

[https://octave.sourceforge.io/symbolic]


Goals
-----

Feature parity with the other symbolic toolboxes.

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
    `sudo apt-get install octave liboctave-dev python-sympy`.
2.  Follow steps 2--5 above.


How to Install on Windows
-------------------------

1.  Get [Octave](http://www.octave.org) for Windows.

2.  Download the `symbolic-win-py-bundle-2.7.0.zip` file from
    [releases](https://github.com/cbm755/octsympy/releases).

3.  Start Octave

4.  At the Octave prompt, type `pkg install symbolic-win-py-bundle-2.7.0.zip`.

5.  At the Octave prompt, type `pkg load symbolic`.

6.  At the Octave prompt, type `syms x`, then `f = (sin(x/2))^3`,
    `diff(f, x)`, etc.

The `symbolic-win-py-bundle` package should have no dependencies other than
Octave (it includes SymPy and a Python interpreter).  Alternatively, you can
install Python and SymPy yourself and use the standard
`pkg install -forge symbolic` command.

If you encounter any difficulties (even minor ones) please read and
if possible help us improve the
[wiki page on Windows Installation](https://github.com/cbm755/octsympy/wiki/Notes-on-Windows-installation).



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
wanted](https://github.com/cbm755/octsympy/issues?q=is:open+is:issue+label:"help+wanted").
Some of these should be quite easy to fix and would be a great way to
get involved.  Come join us!

How to hack on the code:

1.  Clone the repo with git (preferred, but you can use the "Download
    ZIP" instead if you want).

2.  Run Octave in the `octsympy/inst/` directory.  It should be safe
    to do this even if you have the released version of the package
    installed (but not loaded).



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

