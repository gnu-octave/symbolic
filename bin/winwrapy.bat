@echo OFF

REM Copyright 2014-2017 Colin B. Macdonald
REM
REM Copying and distribution of this file, with or without modification,
REM are permitted in any medium without royalty provided the copyright
REM notice and this notice are preserved.  This file is offered as-is,
REM without any warranty.

REM This bat file discards stderr from the python executable.
REM This is a workaround as Octave for Windows cannot tolerate stderr from a popen2
REM subprocess: see [this bug report](https://savannah.gnu.org/bugs/?43036).
REM You'll need to edit this script if your python is called something else.

%1 -i 2> NUL

REM If you are using the windows bundle for octsympy then "octpy.exe" will be used.
REM It is [available online](http://www.orbitals.com/programs/pyexe.html)
REM You may need to include its folder (e.g.,
REM    C:\Octave\Octave-3.8.2\share\octave\package\octsympy-2.1.1\bin)
REM in the windows environment variable %PATH

REM For developers, other options for the stderr:

REM redir stderr to stdout
REM octpy -i 2>&1

REM drop stderr
REM octpy -i 2> NUL

REM log stderr
REM octpy -i 2> stderrlog.txt

REM Fancier logging with busybox/tee
REM del /Q inlog.txt
REM del /Q outlog.txt
REM del /Q stderrlog.txt
REM busybox tee inlog.txt | py -i 2> stderrlog.txt | busybox tee outlog.txt
