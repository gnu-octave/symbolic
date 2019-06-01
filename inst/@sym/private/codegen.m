%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

function [outflag,output] = codegen(varargin)

  [Nin, inputs, inputstr, Nout, param] = codegen_input_parser(varargin{:});

  %fprintf('debug: %d inputs, %d outputs\n', Nin, Nout);

  %% fortran.m/ccode.m
  % these call us with lang
  if (isfield(param, 'lang'))
    assert(strcmpi(param.lang, 'F95') || ...
           strcmpi(param.lang, 'C')   || ...
           strcmpi(param.lang, 'Octave'))
  else
    param.lang = 'Octave';
  end

  if (strcmpi(param.lang, 'Octave'))
    outflag = -1;
    output = {Nin, inputs, inputstr, Nout, param};
    return
  end

  %% Outputs
  if (param.codegen)
    %cmd = { '(expr,fcnname,fname,showhdr) = _ins' ...
    %        'from sympy.utilities.codegen import codegen' ...
    %       ['out = codegen((fcnname,expr), "' param.lang ...
    %        '", filename, header=showhdr)'] ...
    %        'return out,' };

    %if (user_provided_vars)
    cmd = { '(expr,fcnname,filename,showhdr,in_vars) = _ins' ...
            'from sympy.utilities.codegen import codegen' ...
           ['out = codegen((fcnname,expr), "' param.lang ...
            '", filename, header=showhdr' ...
            ', argument_sequence=in_vars)'] ...
            'return out,' };
    %end

    assert(Nout == 1, 'FIXME: multiple inputs?  need names?');

    if isempty(param.fname)
      fname2 = 'file'; fcnname = 'myfun';
    else
      fname2 = param.fname; fcnname = param.fname;
    end
    % was note here about findsymbols vs symvar ordering: not relevant
    out = pycall_sympy__ (cmd, varargin{1}, fcnname, fname2, param.show_header, inputs);
    C.name = out{1}{1};
    C.code = out{1}{2};
    H.name = out{2}{1};
    H.code = out{2}{2};

    if (isempty(param.fname))
      output = {C, H};
      outflag = 2;
    else
      [fid,msg] = fopen(C.name, 'w');
      assert(fid > -1, msg)
      fprintf(fid, '%s', C.code)
      fclose(fid);

      [fid,msg] = fopen(H.name, 'w');
      assert(fid > -1, msg)
      fprintf(fid, '%s', H.code)
      fclose(fid);
      fprintf('Wrote files %s and %s.\n', C.name, H.name);
      output = {};
      outflag = 0;
    end

  else

    if (strcmp(param.lang, 'C'))
      cmd = { '(f,) = _ins'  ...
              's = ccode(f)' ...
              'return s,' };
    elseif (strcmp(param.lang, 'F95'))
      cmd = { '(f,) = _ins'  ...
              's = fcode(f)' ...
              'return s,' };
    else
      error('only C and F95 supported');
    end

    exprstrs = {};
    for i=1:Nout
      expr = varargin{i};
      exprstr{i} = pycall_sympy__ (cmd, expr);
    end

    if (Nout == 1)
      output = {exprstr{1}};
    else
      output = exprstr;
    end
    outflag = 1;
  end
end



function [Nin, inputs, inputstr, Nout, param] = codegen_input_parser(varargin)

  param.codegen = false;
  param.user_provided_vars = false;
  param.show_header = true;
  Nout = -42;

  %% input processing
  % loop over inputs to find: (f1,f2,...,f_{Nout}, param, value)
  i = 0;
  while (i < nargin)
    i = i + 1;
    if (ischar(varargin{i}))
      if (Nout < 0)
        Nout = i-1;
      end

      if strcmpi(varargin{i}, 'vars')
        temp = varargin{i+1};
        i = i + 1;
        param.user_provided_vars = true;
        if (isa(temp, 'sym'))
          inputs = temp;
        elseif (iscell(temp))
          inputs = temp;
          for j=1:length(inputs)
            assert(isa(inputs{j},'sym') || ischar(inputs{j}), ...
                   'only sym/char supported in vars list');
          end
        else
          error('invalid "vars" param');
        end

      elseif strcmpi(varargin{i}, 'file')
        param.codegen = true;
        param.fname = varargin{i+1};
        i = i + 1;

      elseif strcmpi(varargin{i}, 'show_header')
        param.show_header = logical(varargin{i+1});
        i = i + 1;

      elseif strcmpi(varargin{i}, 'lang')
        param.lang = varargin{i+1};
        i = i + 1;

      elseif strcmp(varargin{i}, 'outputs')
        warning('fixme: named "outputs" to be implemented?')
        outs = varargin{i+1}
        i = i + 1;

      else
        error('invalid option')
      end
    end
  end
  if (Nout < 0)
    Nout = nargin;
  end


  for i=1:Nout
    if ~(isa(varargin{i}, 'sym'))
      warning('expected output expressions to be syms');
    end
    if (isa(varargin{i}, 'symfun'))
      warning('FIXME: symfun! does that need special treatment?');
    end
  end


  %% get input string
  if (~param.user_provided_vars)
    inputs = findsymbols(varargin(1:Nout));
  end
  Nin = length(inputs);
  inputstr = strjoin(syms2charcells(inputs), ',');


  %fprintf('debug: %d inputs, %d outputs\n', Nin, Nout);

end


function A = cell2symarray(C)
  A = sym([]);
  for i=1:length(C)
    %A(i) = C{i};  % Issue #17
    idx.type = '()';
    idx.subs = {i};
    A = subsasgn(A, idx, C{i});
  end
end


function C = syms2charcells(S)
  C = {};
  for i=1:length(S)
    if iscell(S)
      if isa(S{i}, 'sym')
        C{i} = S{i}.flat;
      else
        C{i} = S{i};
      end
    else
      % MoFo Issue #17
      %C{i} = S(i).flat
      idx.type = '()';
      idx.subs = {i};
      temp = subsref(S,idx);
      C{i} = temp.flat;
    end
  end
end

