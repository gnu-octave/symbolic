@echo OFF

REM Octave for windows cannot tolerate stderr from a popen2 subprocess
REM This bat file discards stderr from py.exe
REM We look for python.exe and use that if found.  Otherwise we try py.exe.
REM You'll need to edit this script if your python is called something else.

REM This batch file uses the "where" command, which is present only for
REM Windows Server 2003 and later versions. So, for older windows systems (such
REM as Windows XP) only lines 16 or 19 should be kept in the next code block.

REM returns 0 if python.exe is found
where /Q python.exe
IF ERRORLEVEL 1 GOTO else
python.exe -i 2> NUL
goto endif
:else
py.exe -i 2> NUL
:endif

REM If python is not installed in your system, "py.exe" will be used.
REM Please, include its folder (for instance: 
REM    C:\Octave\Octave-3.8.2\\share\octave\package\octosympy-0.0.1\bin     )
REM in the windows environment variable %PATH 

REM Other options for the stderr:

REM redir stderr to stdout
REM py -i 2>&1

REM drop stderr
REM py -i 2> NUL

REM log stderr
REM py -i 2> stderrlog.txt

REM Fancier logging with busybox/tee
REM del /Q inlog.txt
REM del /Q outlog.txt
REM del /Q stderrlog.txt
REM busybox tee inlog.txt | py -i 2> stderrlog.txt | busybox tee outlog.txt
