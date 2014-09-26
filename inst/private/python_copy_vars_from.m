function s = python_copy_vars_from(out, tryexcept)
%private function

  if (nargin == 1)
    tryexcept = true;
  end

  if (~tryexcept)
    %% no error checking
    s = { sprintf('octoutput_drv(%s)', out) };
  else
    %% with try-except block
    s = { 'try:' ...
          sprintf('    octoutput_drv(%s)', out) ...
          'except:' ...
          '    octoutput_drv("PYTHON: Error in var export")' ...
          '    myerr(sys.exc_info())' ...
          '    raise' };
  end
