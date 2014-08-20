@echo OFF

REM Info:
REM "ping" is "sleep" on this lame excuse of an OS
REM ("timeout" won't work if input/output redirected)

echo hello 1, sleeping
PING 1.1.1.1 -n 1 -w 500 > NUL
echo hello 2, sleeping
PING 1.1.1.1 -n 1 -w 500 > NUL
echo hello 3, sleeping
PING 1.1.1.1 -n 1 -w 500 > NUL

echo NOW WE TALK TO STDERR...
echo hello stderr 1>&2
echo Betcha won't see this!

echo hello 4, sleeping
PING 1.1.1.1 -n 1 -w 500 > NUL
echo hello 5, sleeping
PING 1.1.1.1 -n 1 -w 500 > NUL
echo hello 6, sleeping
PING 1.1.1.1 -n 1 -w 500 > NUL
echo goodbye
