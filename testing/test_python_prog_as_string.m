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
