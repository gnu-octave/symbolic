%% Copyright (C) 2014-2019 Colin B. Macdonald
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

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod  @@sym function_handle (@var{f})
%% @defmethodx @@sym function_handle (@var{f1}, @dots{}, @var{fn})
%% @defmethodx @@sym function_handle (@dots{}, @var{param}, @var{value})
%% @defmethodx @@sym function_handle (@dots{}, 'vars', [@var{x} @dots{} @var{z}])
%% @defmethodx @@sym function_handle (@dots{}, 'file', @var{filename})
%% @defmethodx @@sym function_handle (@dots{}, 'outputs', [@var{o1} @dots{} @var{on}])
%% Convert symbolic expression into a standard function.
%%
%% This can make anonymous functions from symbolic expressions:
%% @example
%% @group
%% syms x y
%% f = x^2 + sin(y)
%%   @result{} f = (sym)
%%        2
%%       x  + sin(y)
%% h = function_handle(f)
%%   @result{} h = @@(x, y) x .^ 2 + sin (y)
%% h(2, pi/2)
%%   @result{} ans =  5
%% @end group
%% @end example
%%
%% Multiple arguments correspond to multiple outputs of the
%% function.  For example, the final @code{x} in this example
%% specifies the third output (rather than the input):
%% @example
%% @group
%% h = function_handle(x^2, 5*x, x);
%% [a, b, c] = h(2)
%%   @result{} a = 4
%%   @result{} b = 10
%%   @result{} c = 2
%% @end group
%% @end example
%%
%% The order and number of inputs can be specified:
%% @example
%% @group
%% syms x y z
%% h = function_handle(f, 'vars', [z y x])
%%   @result{} h = @@(z, y, x) x .^ 2 + sin (y)
%% @end group
%% @end example
%%
%% For compatibility with the Symbolic Math Toolbox in Matlab, we
%% provide a synonym: @pxref{@@sym/matlabFunction}
%%
%% OctSymPy can also generate an @code{.m} file from a symbolic
%% expression by passing the keyword @code{file} with a string
%% argument for @var{filename}.  A handle to the function in the
%% file will be returned.
%% Passing an empty @var{filename} creates an anonymous function:
%% @example
%% @group
%% h = function_handle(f, 'file', '')
%%   @result{} h = @@(x, y) x .^ 2 + sin (y)
%% @end group
%% @end example
%%
%% FIXME: naming outputs with @var{PARAM} as @code{outputs}
%% not implemented.
%%
%% FIXME: does not ``optimize'' code, for example, using common
%% subexpression elimination.
%%
%% @seealso{@@sym/ccode, @@sym/fortran, @@sym/latex, @@sym/matlabFunction}
%% @end defmethod


function f = function_handle(varargin)

  % We use the private/codegen function only for its input parsing
  [flg, meh] = codegen(varargin{:}, 'lang', 'octave');
  assert(flg == -1);
  [Nin, inputs, inputstr, Nout, param] = deal(meh{:});


  %% Outputs
  if (param.codegen) && (~isempty(param.fname))
    cmd = { '(expr,fcnname,filename,showhdr,in_vars) = _ins' ...
            'from sympy.utilities.codegen import codegen' ...
            'try:' ...
           ['    out = codegen((fcnname,expr), "' param.lang ...
            '", filename, header=showhdr' ...
            ', argument_sequence=in_vars)'] ...
            'except ValueError as e:' ...
            '    return (False, str(e))' ...
            'return (True, out)' };

    [fcnpath, fcnname, fcnext] = fileparts(param.fname);
    [worked, out] = pycall_sympy__ (cmd, varargin(1:Nout), fcnname, fcnname, param.show_header, inputs);

    if (~worked)
      if (strcmp(out, 'Language ''octave'' is not supported.'))
        error('function_handle: your SymPy has no octave codegen');
      else
        out
        error('function_handle: Some other error from SymPy code gen?  file a bug!');
      end
    end
    M.name = out{1}{1};
    M.code = out{1}{2};

    assert (strcmp (M.name, [fcnname '.m']), 'sanity check failed: names should match');

    file_to_write = fullfile(fcnpath, [fcnname '.m']);
    [fid,msg] = fopen(file_to_write, 'w');
    assert(fid > -1, msg)
    fprintf(fid, '%s', M.code);
    fclose(fid);
    fprintf('Wrote file %s.\n', file_to_write);

    % FIXME: Check upstream to rehash the files correctly once created
    % Due to an upstream bug in octave on windows, we have to wait for the file to be loaded.
    % See https://savannah.gnu.org/bugs/?31080 for more information...\n
    if (exist('OCTAVE_VERSION', 'builtin') && ispc())
      fprintf('Workaround savannah.gnu.org/bugs/?31080: waiting for %s... ', fcnname);
      fflush(stdout);
      while (exist(fcnname) == 0)
        rehash()
        pause(1)
      end
      fprintf('Found!\n');
    end

    f = str2func(fcnname);

  else % output function handle

    exprstrs = {};
    for i=1:Nout
      expr = varargin{i};
      cmd = { '(f,) = _ins' ...
              'try:' ...
              '    a, b, s = octave_code(f, human=False)' ...
              'except NameError as e:' ...
              '    return (False, str(e))' ...
              'if len(b) != 0:' ...
              '    return (False, s)' ...
              'if len(a) != 0:' ...
              '    return (False, "expected symbols-to-declare to be empty")' ...
              'return (True, s)' };
      [worked, codestr] = pycall_sympy__ (cmd, expr);
      if (~worked)
        error('function_handle: python codegen failed: %s', codestr)
      end
      exprstr{i} = codestr;
    end

    if (Nout == 1)
      f = eval(sprintf('@(%s) %s', inputstr, exprstr{1}));
    else
      str = [ sprintf('@(%s) deal(', inputstr) ...
              sprintf('%s,', exprstr{:})];
      str = [str(1:end-1) ')'];
      f = eval(str);
    end
  end

  % Note: this fails in Matlab SMT too:
  %h = function_handle({x,y,z},'vars',{x y z})
  % (could fix by moving it outside @sym)
end


%!shared x,y,z
%! syms x y z

%!test
%! % basic test
%! h = function_handle(2*x);
%! assert(isa(h, 'function_handle'))
%! assert(h(3)==6)

%!test
%! % autodetect inputs
%! h = function_handle(2*x*y, x+y);
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % specified inputs
%! h = function_handle(2*x*y, 'vars', [x y]);
%! assert(h(3,5)==30)
%! h = function_handle(2*x*y, x+y, 'vars', [x y]);
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays for vars list
%! h = function_handle(2*x*y, x+y, 'vars', {x y});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)
%! h = function_handle(2*x*y, x+y, 'vars', {'x' 'y'});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays specfies order, overriding symvar order
%! h = function_handle(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = function_handle(x*y, 12/y, 'vars', [y x]);
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!test
%! % cell arrays specfies order, overriding symvar order
%! h = function_handle(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = function_handle(x*y, 12/y, 'vars', [y x]);
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!test
%! % Functions with different names in Sympy.
%! f = abs(x);  % becomes Abs(x)
%! h = function_handle(f);
%! assert(h(-10) == 10)
%! f = ceil(x);
%! h = function_handle(f);
%! assert(h(10.1) == 11)

%!test
%! % 'file' with empty filename returns handle
%! h = function_handle(2*x*y, 'file', '');
%! assert(isa(h, 'function_handle'))
%! assert(h(3,5)==30)
%! h = function_handle(2*x*y, 'vars', {x y}, 'file', '');
%! assert(isa(h, 'function_handle'))
%! assert(h(3,5)==30)

%!test
%! % output to disk
%! fprintf('\n')
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   temp_file = tempname('', 'oct_');
%! else
%!   temp_file = tempname();
%! end
%! % allow loading function from temp_file
%! [temp_path, ans, ans] = fileparts(temp_file);
%! addpath(temp_path);
%! f = function_handle(2*x*y, 2^x, 'vars', {x y z}, 'file', temp_file);
%! assert( isa(f, 'function_handle'))
%! addpath(temp_path);  % Matlab 2014a needs this?
%! [a,b] = f(10,20,30);
%! assert (isnumeric (a) && isnumeric (b))
%! assert (a == 400)
%! assert (b == 1024)
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   assert (unlink([temp_file '.m']) == 0)
%! else
%!   delete ([temp_file '.m'])
%! end
%! % remove temp_path from load path
%! rmpath(temp_path);

%!test
%! % output to disk: also works with .m specified
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   temp_file = [tempname('', 'oct_') '.m'];
%! else
%!   temp_file = [tempname() '.m'];
%! end
%! % allow loading function from temp_file
%! [temp_path, ans, ans] = fileparts(temp_file);
%! addpath(temp_path);
%! f = function_handle(2*x*y, 2^x, 'vars', {x y z}, 'file', temp_file);
%! assert( isa(f, 'function_handle'))
%! addpath(temp_path);  % Matlab 2014a needs this?
%! [a,b] = f(10,20,30);
%! assert (isnumeric (a) && isnumeric (b))
%! assert (a == 400)
%! assert (b == 1024)
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   assert (unlink(temp_file) == 0)
%! else
%!   delete (temp_file)
%! end
%! % remove temp_path from load path
%! rmpath(temp_path);

%!test
%! % non-scalar outputs
%! H = [x y z];
%! M = [x y; z 16];
%! V = [x;y;z];
%! h = function_handle(H, M, V);
%! [t1,t2,t3] = h(1,2,3);
%! assert(isequal(t1, [1 2 3]))
%! assert(isequal(t2, [1 2; 3 16]))
%! assert(isequal(t3, [1;2;3]))

%!test
%! % non-scalar outputs in .m files
%! H = [x y z];
%! M = [x y; z 16];
%! V = [x;y;z];
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   temp_file = tempname('', 'oct_');
%! else
%!   temp_file = tempname();
%! end
%! % allow loading function from temp_file
%! [temp_path, ans, ans] = fileparts(temp_file);
%! addpath(temp_path);
%! h = function_handle(H, M, V, 'vars', {x y z}, 'file', temp_file);
%! assert( isa(h, 'function_handle'))
%! addpath(temp_path);  % Matlab 2014a needs this?
%! [t1,t2,t3] = h(1,2,3);
%! assert(isequal(t1, [1 2 3]))
%! assert(isequal(t2, [1 2; 3 16]))
%! assert(isequal(t3, [1;2;3]))
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   assert (unlink([temp_file '.m']) == 0)
%! else
%!   delete ([temp_file '.m'])
%! end
%! % remove temp_path from load path
%! rmpath(temp_path);

%!test
%! % order of outputs is lexiographic
%! syms a A x y
%! f = y + 10*a + 100*x + 1000*A;
%! h = function_handle(f);
%! assert (h(1, 2, 3, 4) == 1000 + 20 + 300 + 4)

%!test
%! % https://github.com/cbm755/octsympy/issues/854
%! f = function_handle (x + 1i*sqrt (sym(3)));
%! assert (f (1), complex (1, sqrt (3)), -eps)
