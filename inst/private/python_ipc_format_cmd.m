function s = python_ipc_format_cmd(cmd, tryexcept)
%private function

  % cmd will be a snippet of python code that does something
  % with _ins and produce _outs.

  if (nargin == 1)
    tryexcept = true;
  end

  if (~tryexcept)
    %% no error checking
    s = sprintf('%s\n\n\n', cmd);
  else
    %% with try-except block
    newl = sprintf('\n');
    % replace blank lines w/ empty comments
    cmd = strrep(cmd, [newl newl], [newl '#' newl]);
    % indent each line by 4 spaces to put inside try-catch
    cmd = strrep(cmd, newl, [newl '    ']);

    s = sprintf([ ...
         'try:\n' ...
         '    %s\n' ...
         'except:\n' ...
         '    octoutput_drv("PYTHON: Error in cmd")\n' ...
         '    myerr(sys.exc_info())\n' ...
         '    raise\n' ...
         '\n\n' ], cmd);
  end



