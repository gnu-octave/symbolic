Notes on Octave-Python IPC
==========================

This directory contains some testing codes.

We currently have three mechanisms.

1. creating a temp file and calling it with system('python temp.py')

2. system() with passing program on command line via 'python -c'.

3. popen2().  The faster approach, should be default.



IPC on GNU/Linux
----------------

Developement environment, all three mechanisms work.



IPC experiments on Windows
--------------------------

1) temp file works on windows w/ py.exe and python.org win install

2) system doesn't work on either, perhaps cmd.exe multiline
   todo write test for this, even just with sort?

3) popen2 works in principle on windows
   a. python install works w/ some tests (but not full octsympy yet?).
   b. py.exe has bug with pipes, reported, wait for 2.7.8 release.



IPC on Mac OS X
---------------

Not tested.
