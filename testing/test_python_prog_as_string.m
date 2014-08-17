%% Test python -c with newlines in the command

%% Baseline
% works on GNU/Linux and Windows
bigs1 = 'import sys; print(42);'

%% real embedded newlines
% works on GNU/Linux, fails on windows
% todo: experiment with \r\n, no reason it should work as sprintf
% will do that anyway...?
bigs2 = 'import sys\nprint(42);'
bigs2 = sprintf(bigs2)

%% escaped newlines
% fails on GNU/Linux, not expected to work
bigs3 = 'import sys\nprint(42);'

[st1,out1] = system(['python -c "' bigs1 '"'])

[st2,out2] = system(['python -c "' bigs2 '"'])

[st3,out3] = system(['python -c "' bigs3 '"'])

%% idea: use exec()

# triple slash quote
s4 = 'exec(\"def p(x):\n    print(x)\np(42)\np(\\\"p\\\")\")'

# with single quote: escaped just for entry into octave
s5 = 'exec(\"def p(x):\n    print(x)\np(42)\np(\\\"p\\\")\np(''jk'')\")'


[st4,out4] = system(['python -c "' s4 '"'])

[st5,out5] = system(['python -c "' s5 '"'])


