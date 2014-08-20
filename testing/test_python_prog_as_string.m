%% Test python -c with newlines in the command

%pyexec = 'python'
pyexec = 'n:\win32\octsympy.git\testing\py.exe'

%% Baseline
% works on GNU/Linux and Windows
bigs1 = 'import sys; print(42)'

%% real embedded newlines
% works on GNU/Linux, fails on windows
% todo: experiment with \r\n, no reason it should work as sprintf
% will do that anyway...?
bigs2 = 'import sys\nprint(42)'
bigs2 = sprintf(bigs2)


[st1,out1] = system([pyexec ' -c "' bigs1 '"'])

[st2,out2] = system([pyexec ' -c "' bigs2 '"'])

disp('----------------------------------------')
%% escaped newlines
% fails on GNU/Linux, not expected to work
bigs3 = 'import sys\nprint(42)'
[st3,out3] = system([pyexec ' -c "' bigs3 '"'])

disp('----------------------------------------')
%% idea: use exec()

# triple slash quote
s4 = 'exec(\"def p(x):\n    print(x)\np(42)\np(\\\"p\\\")\")'

# with single quote: escaped just for entry into octave
s5 = 'exec(\"def p(x):\n    print(x)\np(42)\np(\\\"p\\\")\np(''jk'')\")'


[st4,out4] = system([pyexec ' -c "' s4 '"'])

[st5,out5] = system([pyexec ' -c "' s5 '"'])


