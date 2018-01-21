%% Copyright (C) 2014-2018 Colin B. Macdonald
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

function convert_comments (basedir, subdir, dirout)
% this slightly strange way of doing things (basedir, subdir) is
% b/c I must "chdir" into base, but get_first_help_sentence() must
% not be in the class dir...

  %basedir, subdir, dirout
  files = dir([basedir subdir]);
  chdir(basedir)

  for i=1:length(files)
    if (~files(i).isdir)
      [dir, name, ext] = fileparts(files(i).name);
      if (strcmp(ext, '.m'))
        if isempty(subdir)
          octname = [name ext];
        else
          octname = [subdir '/' name ext];
        end
        fprintf('Converting texinfo to Matlab-style documentation: %s\n', octname)
        r = convert_oct_2_ml (octname, [dirout octname]);
        if ~r
          [status, msg, msgid] = copyfile (octname, [dirout octname], 'f');
          if (status ~= 1)
            error(msg)
          end
          fprintf('**** COPYING %s UNMODIFIED ****\n', octname)
        end
      end
    end
  end
end




function success = convert_oct_2_ml (fname, foutname)

  [dir, fcn, ext] = fileparts(fname);

  newl = sprintf('\n');

  [fi,msg] = fopen(fname, 'r');
  if (fi < 0)
    error(msg)
  end

  ins = {}; i = 0;
  while (1)
    temp = fgets(fi);
    if ~ischar(temp) && temp == -1
      break
    end
    i = i + 1;
    ins{i} = temp;
    % todo, possible strip newl
  end

  fclose(fi);

  % trim newlines
  ins = deblank(ins);


  %% find the actual function [] = ... line
  Nfcn = [];
  for i = 1:length(ins)
    I = strfind (ins{i}, 'function');
    if ~isempty(I) && I(1) == 1
      %disp ('found function header')
      Nfcn = i;
      break
    end
  end
  if isempty(Nfcn)
    disp('AFAICT, this is a script, not a function')
    success = false;
    return
  end


  %% copyright block
  [cr,N] = findblock(ins, 1);
  if (Nfcn < N)
    warning('function header in first block (where copyright block should be), not converting')
    success = false;
    return
  end
  cr = ltrim(cr, 3);

  % cut 2nd line if empty
  if isempty(cr{2})
    cr2 = cell(1,length(cr)-1);
    cr2(1) = cr(1);
    cr2(2:end) = cr(3:end);
    cr = cr2;
  end

  cr = prepend_each_line(cr, '%', ' ');
  cr{1} = ['%' cr{1}];
  copyright_summary = 'This is free software under the GPL, see .m file for full details.';
  % alternative for BSD:
  %copyright_summary = 'This is free software, see .m file for license.';


  %% use block
  % we don't parse this, just call get_help_text
  temp = ins{N};
  if ~strcmp(temp, '%% -*- texinfo -*-')
    error('can''t find the texinfo line, aborting')
    %success = false;
    %return
  end

  %% the "lookfor" line
  lookforstr = get_first_help_sentence (fname);
  if (~isempty(strfind(lookforstr, newl)))
    lookforstr
    error('lookfor string contains newline: missing period? too long? some other issue?')
    %success = false;
    %return
  end
  if (length(lookforstr) > 76)
    error(sprintf('lookfor string of length %d deemed too long', length(lookforstr)))
  end


  %% get the texinfo source, and format it
  [text, form] = get_help_text(fname);
  if ~strcmp(form, 'texinfo')
    text
    form
    error('formatted incorrectly, help text not texinfo')
  end
  usestr = __makeinfo__(text, 'plain text');



  %% remove the lookforstr from the text
  I = strfind(usestr, lookforstr);
  if length(I) ~= 1
    I
    lookforstr
    usestr
    error('too many lookfor lines?')
  end
  len = length(lookforstr);
  J = I + len;

  % if usestr has only a lookfor line then no need to see what's next
  if (J < length(usestr))
    % find next non-empty char
    %while isspace(usestr(J))
    %  J = J + 1;
    %end

    % let's be more conservative trim newline in usual case:
    if ~isspace(usestr(J))
      error('no space or newline after lookfor line?');
    end
    J = J + 1;
  end

  usestr = usestr([1:(I-1) J:end]);

  use = strsplit(usestr, newl, 'CollapseDelimiters', false);

  %% 2017: we have more choices than "-- Function File"
  % just trim "--" so it doesn't break indents
  def_line_has_function_name = false;
  for i=1:length(use)
    if regexp(use{i}, '^ -- ')
      if (~ isempty(strfind(use{i}, [' ' fcn])))
        def_line_has_function_name = true;
      end
    end
    use{i} = regexprep(use{i}, '^ -- ', '     ');
  end
  %usestr = strrep(usestr, lookforstr, '');
  if (~ def_line_has_function_name)
    warning('function @deftypefn line may not include function name:')
    use{i}
  end

  use = ltrim(use, 2);
  while isempty(use{end})
    use = use(1:end-1);
  end


  %% the rest
  N = Nfcn;
  fcn_line = ins{N};

  % sanity checks
  I = strfind(ins{N+1}, '%');
  if ~isempty(I) && I(1) == 1
    ins{N}
    ins{N+1}
    error('possible duplicate comment header following function')
  end

  therest = ins(N+1:end);



  %% Output
  [f, msg] = fopen(foutname, 'w');
  if (f < 0)
    msg
    error('failed to open file for writing')
  end

  fdisp(f, fcn_line)

  fprintf(f, '%%%s  %s\n', upper(fcn), lookforstr)

  for i=1:length(use)
    fprintf(f, '%%%s\n', use{i});
  end

  fdisp(f, '%');
  fprintf(f, '%%   %s\n', copyright_summary);

  %fdisp(f, '%');
  %fdisp(f, '%   [Genereated from a GNU Octave .m file, edit that instead.]');

  %fprintf(f,(s)

  fdisp(f, '');
  fdisp(f, '%% Note for developers');
  fdisp(f, '% This file is autogenerated from a GNU Octave .m file.');
  fdisp(f, '% If you want to edit, please make changes to the original instead');

  fdisp(f, '');
  for i=1:length(cr)
    fprintf(f, '%s\n', cr{i});
  end

  fdisp(f, '');

  for i=1:length(therest)
    fprintf(f, '%s\n', therest{i});
  end

  fclose(f);

  success = true;

end


function [block,endl] = findblock(f, j)
  block = {}; c = 0;
  %newl = sprintf('\n');
  for i = j:length(f)
    temp = f{i};
    %if (strcmp(temp, newl))
    if (isempty(temp))
      endl = i + 1;
      break
    end
    c = c + 1;
    block{c} = temp;
  end
end


function g = ltrim(f, n)
  g = {};
  for i = 1:length(f)
    temp = f{i};
    if length(temp) < n
      g{i} = '';
    else
      g{i} = substr(temp, n+1);
    end
  end
end


function g = prepend_each_line(f, pre, pad)
  g = {};
  for i = 1:length(f)
    temp = f{i};
    if isempty(temp)
      g{i} = pre;
    else
      g{i} = [pre pad temp];
    end
  end
end
