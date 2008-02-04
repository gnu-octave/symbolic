## Copyright (C) 2003 Willem J. Atsma
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[ @var{x},@var{inf},@var{msg} ] =} symfsolve (...)
## Solve a set of symbolic equations using fsolve(). There are a number of
## ways in which this function can be called.
##
## This solves for all free variables, initial values set to 0:
##
## @example
## symbols
## x=sym("x");   y=sym("y");
## f=x^2+3*x-1;  g=x*y-y^2+3;
## a = symfsolve(f,g);
## @end example
##
## This solves for x and y and sets the initial values to 1 and 5 respectively:
##
## @example
## a = symfsolve(f,g,x,1,y,5);
## a = symfsolve(f,g,@{x==1,y==5@});
## a = symfsolve(f,g,[1 5]);
## @end example
##
## In all the previous examples vector a holds the results: x=a(1), y=a(2).
## If initial conditions are specified with variables, the latter determine
## output order:
##
## @example
## a = symfsolve(f,g,@{y==1,x==2@});  # here y=a(1), x=a(2)
## @end example
##
## The system of equations to solve for can be given as separate arguments or
## as a single list/cell-array:
##
## @example
## a = symfsolve(@{f,g@},@{y==1,x==2@});  # here y=a(1), x=a(2)
## @end example
##
## If the variables are not specified explicitly with the initial conditions,
## they are placed in alphabetic order. The system of equations can be comma-
## separated or given in a list or cell-array. The return-values are those of
## fsolve; @var{x} holds the found roots.
## @end deftypefn
## @seealso{fsolve}

## Author: Willem J. Atsma <watsma(at)users.sf.net>
## 
## 2003-04-22 Willem J. Atsma <watsma(at)users.sf.net>
## * Initial revision

function [ x,inf,msg ] = symfsolve (varargin)

	#separate variables and equations
	eqns = list;
	vars = list;

	if iscell(varargin{1}) | islist(varargin{1})
		if !strcmp(typeinfo(varargin{1}{1}),"ex")
			error("First argument must be (a cell-array/list of) symbolic expressions.")
		endif
		eqns = varargin{1};
		arg_count = 1;
	else
		arg_count = 0;
		for i=1:nargin
			tmp = disp(varargin{i});
			if( iscell(varargin{i}) | islist(varargin{i}) | ...
					all(isalnum(tmp) | tmp=="_" | tmp==",") | ...
					!strcmp(typeinfo(varargin{i}),"ex") )
				break;
			endif
			eqns=append(eqns,varargin{i});
			arg_count = arg_count+1;
		endfor
	endif
	neqns = length(eqns);
	if neqns==0
		error("No equations specified.")
	endif

	# make a list with all variables from equations
	tmp=eqns{1};
	for i=2:neqns
		tmp = tmp+eqns{i};
	endfor
	evars = findsymbols(tmp);
	nevars=length(evars);

	# After the equations may follow initial values. The formats are:
	# 	[0 0.3 -3 ...]
	# 	x,0,y,0.3,z,-3,...
	# 	{x==0, y==0.3, z==-3 ...}
	# 	none - default of al zero initial values

	if arg_count==nargin
		vars = evars;
		nvars = nevars;
		X0 = zeros(nvars,1);
	elseif (nargin-arg_count)>1
		if mod(nargin-arg_count,2)
			error("Initial value symbol-value pairs don't match up.")
		endif
		for i=(arg_count+1):2:nargin
			tmp = disp(varargin{i});
			if all(isalnum(tmp) | tmp=="_" | tmp==",")
				vars=append(vars,varargin{i});
				X0((i-arg_count+1)/2)=varargin{i+1};
			else
				error("Error in symbol-value pair arguments.")
			endif
		endfor
		nvars = length(vars);
	else
		nvars = length(varargin{arg_count+1});
		if nvars!=nevars
			error("The number of initial conditions does not match the number of free variables.")
		endif
		if iscell(varargin{arg_count+1}) | islist(varargin{arg_count+1})
			# List/cell-array of relations - this should work for a list of strings ("x==3") too.
			for i=1:nvars
				tmp = disp(varargin{arg_count+1}{i});
				vars = append(vars,sym(strtok(tmp,"==")));
				X0(i) = str2num(tmp((findstr(tmp,"==")+2):length(tmp)));
			endfor
		else
			# straight numbers, match up with symbols in alphabetic order
			vars = evars;
			X0 = varargin{arg_count+1};
		endif
	endif

	# X0 is now a vector, vars a list of variables.
	# create temporary function:
	symfn = sprintf("function Y=symfn(X) ");
	for i=1:nvars
		symfn = [symfn sprintf("%s=X(%d); ",disp(vars{i}),i)];
	endfor
	for i=1:neqns
		symfn = [symfn sprintf("Y(%d)=%s; ",i,disp(eqns{i}))];
	endfor
	symfn = [symfn sprintf("endfunction")];

	eval(symfn);
	[x,inf,msg] = fsolve("symfn",X0);

endfunction
