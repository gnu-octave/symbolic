function L = python_sympy_cmd_retcell(cmd, varargin)
%PYTHON_SYMPY_CMD_RETCELL  Run SympPy cmd, return symbolic expression list
%   See PYTHON_SYMPY_CMD

  A = python_sympy_cmd_raw(cmd, varargin{:});

  M = length(A)/2;
  assert(rem(M,1) == 0)
  L = cell(1,M);
  for i=1:M
    %s = [];
    %s.text = A{2*i-1};
    %s.pickle = A{2*i};
    %s = class(s, 'sym');
    text = A{2*i-1};
    pickle = A{2*i};
    %pickle = undo_string_escapes (A{2*i});

    %true_pickle = sprintf('I01\n.');
    %false_pickle = sprintf('I00\n.');
    true_pickle = sprintf('True');
    false_pickle = sprintf('False');

    if (strcmp(pickle, true_pickle))
      s = true;
    elseif (strcmp(pickle, false_pickle))
      s = false;
    else
      s = sym(text, pickle);
    end

    L{i} = s;
  end

