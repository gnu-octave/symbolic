@echo OFF

REM Octave for windows cannot tolerate stderr from a popen2 subprocess
REM This bat file discards stderr from py.exe
REM We look for python.exe and use that if found.  Otherwise we try py.exe.
REM You'll need to edit this script if your python is called something else.

REM returns 0 if python.exe is found
where /Q python.exe
IF ERRORLEVEL 1 GOTO else
python.exe -i 2> NUL
goto endif
:else
py.exe -i 2> NUL
:endif

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
