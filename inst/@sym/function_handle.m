%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{g} =} function_handle (@var{f})
%% @deftypefnx {Function File} {@var{g} =} function_handle (@var{f1}, @dots{}, @var{fn})
%% @deftypefnx {Function File} {@var{g} =} function_handle (@dots{}, @var{param}, @var{value})
%% @deftypefnx {Function File} {@var{g} =} function_handle (@dots{}, 'vars', [@var{x} @dots{} @var{z}])
%% @deftypefnx {Function File} {@dots{}} function_handle (@dots{}, 'file', @var{filename})
%% @deftypefnx {Function File} {@dots{}} function_handle (@dots{}, 'outputs', [@var{o1} @dots{} @var{on}])
%% Convert symbolic expression into a standard function.
%%
%% This can make anonymous functions from symbolic expressions:
%% @example
%% @group
%% >> syms x y
%% >> f = x^2 + sin(y)
%%    @result{} f = (sym)
%%         2
%%        x  + sin(y)
%% >> h = function_handle(f)
%%    @result{} h =
%%      @@(x, y) x .^ 2 + sin (y)
%% @end group
%% @end example
%%
%% The order and number of inputs can be specified:
%% @example
%% @group
%% >> syms x y z
%% >> h = function_handle(f, 'vars', [z y x])
%%    @result{} h =
%%      @@(z, y, x) x .^ 2 + sin (y)
%% @end group
%% @end example
%%
%% For compatibility with the Symbolic Math Toolbox in Matlab, we
%% provide a synonym: @xref{matlabFunction}
%%
%% OctSymPy can also generate an @code{.m} file from a symbolic
%% expression by passing the keyword @code{file} with a string
%% argument for @var{filename}.  A handle to the function in the
%% file will be returned.
%% Passing an empty @var{filename} creates an anonymous function:
%% @example
%% @group
%% >> h = function_handle(f, 'file', '')
%%    @result{} h =
%%      @@(x, y) x .^ 2 + sin (y)
%% @end group
%% @end example
%%
%% FIXME: naming outputs with @var{PARAM} as
%% 'outputs' not implemented.
%%
%% FIXME: does not ``optimize'' code, for example, using common
%% subexpression elimination.
%%
%% The routine relies on code generation features added to SymPy
%% 0.7.6.  On earlier versions, the workaround only works for
%% very simple expressions such as polynomials and trig functions.
%%
%% @seealso{ccode, fortran, latex, matlabFunction}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function f = function_handle(varargin)

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

    % if filename ends with .m, do not add another
    if strcmpi(param.fname(end-1:end), '.m')
      param.fname = param.fname(1:end-2);
    end

    fname2 = param.fname; fcnname = param.fname;
    % was old note about findsymbols vs symvar: not relevant
    [worked, out] = python_cmd (cmd, varargin(1:Nout), fcnname, fname2, param.show_header, inputs);

    if (~worked)
      if (strcmp(out, 'Language ''octave'' is not supported.'))
	error('function_handle: your SymPy has no octave codegen, cannot workaround');
      else
	ou
	error('function_handle: Some other error from SymPy code gen?  file a bug!');
      end
    end
    M.name = out{1}{1};
    M.code = out{1}{2};

    [fid,msg] = fopen(M.name, 'w');
    assert(fid > -1, msg)
    fprintf(fid, '%s', M.code)
    fclose(fid);
    fprintf('Wrote file %s.\n', M.name);
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
      [worked, codestr] = python_cmd (cmd, expr);
      %worked = false;
      if (worked)
        codestr = vectorize(codestr);
      else
        %% SymPy 0.7.5 has no octave_code command
        % Use a crude workaround (e.g., Abs, ceiling will fail).
        if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75 ...
            && strcmp(codestr, 'global name ''octave_code'' is not defined'))
          warning('OctSymPy:function_handle:nocodegen', ...
                  'function_handle: your SymPy has no octave codegen: partial workaround');
          codestr = expr.flat;
          % Matlab: ** to ^ substition.  On Octave, vectorize does this
          codestr = strrep(codestr, '**', '^');
          codestr = vectorize(codestr);
        else
          error('function_handle: python codegen failed: %s', codestr)
        end
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
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(2*x);
%! warning(s)
%! assert(isa(h, 'function_handle'))
%! assert(h(3)==6)

%!test
%! % autodetect inputs
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(2*x*y, x+y);
%! warning(s)
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % specified inputs
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(2*x*y, 'vars', [x y]);
%! assert(h(3,5)==30)
%! h = function_handle(2*x*y, x+y, 'vars', [x y]);
%! warning(s)
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays for vars list
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(2*x*y, x+y, 'vars', {x y});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)
%! h = function_handle(2*x*y, x+y, 'vars', {'x' 'y'});
%! warning(s)
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays specfies order, overriding symvar order
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = function_handle(x*y, 12/y, 'vars', [y x]);
%! warning(s)
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!test
%! % cell arrays specfies order, overriding symvar order
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = function_handle(x*y, 12/y, 'vars', [y x]);
%! warning(s)
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!xtest
%! % Functions with different names in Sympy.
%! % (will fail unless Sympy has Octave codegen)
%! f = abs(x);  % becomes Abs(x)
%! h = function_handle(f);
%! assert(h(-10) == 10)
%! f = ceil(x);
%! h = function_handle(f);
%! assert(h(10.1) == 11)

%!test
%! % 'file' with empty filename returns handle
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = function_handle(2*x*y, 'file', '');
%! assert(isa(h, 'function_handle'))
%! assert(h(3,5)==30)
%! h = function_handle(2*x*y, 'vars', {x y}, 'file', '');
%! warning(s)
%! assert(isa(h, 'function_handle'))
%! assert(h(3,5)==30)

%!xtest
%! % output to disk
%! % (will fail unless Sympy has Octave codegen)
%! f = function_handle(2*x*y, 2^x, 'vars', {x y z}, 'file', 'temp_test_output1');
%! assert( isa(f, 'function_handle'))
%! [a,b] = f(10,20,30);
%! assert (isnumeric (a) && isnumeric (b))
%! assert (a == 400)
%! assert (b == 1024)
%! delete('temp_test_output1.m')

%!xtest
%! % output to disk: also works with .m specified
%! % (will fail unless Sympy has Octave codegen)
%! f = function_handle(2*x*y, 2^x, 'vars', {x y z}, 'file', 'temp_test_output2.m');
%! assert( isa(f, 'function_handle'))
%! [a,b] = f(10,20,30);
%! assert (isnumeric (a) && isnumeric (b))
%! assert (a == 400)
%! assert (b == 1024)
%! delete('temp_test_output2.m')

%!xtest
%! % non-scalar outputs
%! % (will fail unless Sympy has Octave codegen)
%! H = [x y z];
%! M = [x y; z 16];
%! V = [x;y;z];
%! h = function_handle(H, M, V);
%! [t1,t2,t3] = h(1,2,3);
%! assert(isequal(t1, [1 2 3]))
%! assert(isequal(t2, [1 2; 3 16]))
%! assert(isequal(t3, [1;2;3]))

%!xtest
%! % non-scalar outputs in .m files
%! % (will fail unless Sympy has Octave codegen)
%! H = [x y z];
%! M = [x y; z 16];
%! V = [x;y;z];
%! h = function_handle(H, M, V, 'vars', {x y z}, 'file', 'temp_test_output3');
%! assert( isa(h, 'function_handle'))
%! [t1,t2,t3] = h(1,2,3);
%! assert(isequal(t1, [1 2 3]))
%! assert(isequal(t2, [1 2; 3 16]))
%! assert(isequal(t3, [1;2;3]))
%! delete('temp_test_output3.m')

%!test
%! % order of outputs is lexiographic
%! syms a A x y
%! f = y + 10*a + 100*x + 1000*A;
%! h = function_handle(f);
%! assert (h(1, 2, 3, 4) == 1000 + 20 + 300 + 4)
