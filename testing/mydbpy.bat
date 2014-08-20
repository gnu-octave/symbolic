@echo OFF

REM Octave for windows cannot tolerate stderr from a popen2 subprocess
REM This bat file discards stderr from py.exe

REM redir stderr to stdout
REM py -i 2>&1

REM drop stderr
py -i 2> NUL

REM log stderr
REM py -i 2> stderrlog.txt

REM Fancier logging with busybox/tee
REM del /Q inlog.txt
REM del /Q outlog.txt
REM del /Q stderrlog.txt
REM busybox tee inlog.txt | py -i 2> stderrlog.txt | busybox tee outlog.txt
