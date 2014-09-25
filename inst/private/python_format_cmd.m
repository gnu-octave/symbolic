function s = python_format_cmd(cmd, tryexcept)
%private function

  % cmd will be a snippet of python code that does something
  % with _ins and produce _outs.

  if (nargin == 1)
    tryexcept = true;
  end

  if (~tryexcept)
    %% no error checking
    s = cmd;
  else
    %% with try-except block

    % replace blank lines w/ empty comments
    I = cellfun(@isempty, cmd);
    % cmd(I) = '#';  % fails on matlab
    cmd(I) = repmat({'#'}, 1, nnz(I));

    cmd = indent_lines(cmd, 4);

    s = { 'try:' ...
          cmd{:} ...
          'except:' ...
          '    octoutput_drv("PYTHON: Error in cmd")' ...
          '    myerr(sys.exc_info())' ...
          '    raise' };
  end



