/*
Copyright (C) 2003 Willem J. Atsma

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

Based on differentiate.cc by Ben Sapp (2002).
*/
#include <octave/oct.h>

#include <ginac/ginac.h>
#include "ov-ex.h"
#include "ov-relational.h"
#include "symbols.h" 

DEFUN_DLD(symlsolve,args,nargout,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {@var{sols} =} symlsolve(@var{eqns},@var{vars})\n\
\n\
Apply the GiNaC lsolve() method to the given linear system of equations and\n\
variables. @var{eqns} and @var{vars} must be single symbolic expressions or\n\
lists/cell-arrays of these. The return value @var{sols} is a list of\n\
symbolic solutions corresponding  in order to @var{vars}.\n\
@end deftypefn")
{
	GiNaC::lst eqns, vars;
	GiNaC::relational relation;
	GiNaC::ex expression, sols;
	octave_value_list oct_sols;
	octave_value retval;
	int i, nargin = args.length();
	
	if (nargin != 2) {
		error("Need 2 arguments.");
		return retval;
	}
	
	try {
		if(args(0).is_list() || args(0).is_cell()) {
			octave_value_list oct_eqn_list(args(0).list_value());
			for(i=0;i<oct_eqn_list.length();i++) {
				if(!get_relation(oct_eqn_list(i),relation)) {
					if(!get_expression(oct_eqn_list(i),expression)) {
						error("Equation %d is not a valid expression.",i+1);
						return retval;
					} else relation = (expression==0);
				}
				eqns.append(relation);
			}
		} else {
			if(!get_relation(args(0),relation)) {
				if(!get_expression(args(0),expression)) {
					error("Equation is not a valid expression.");
					return retval;
				} else relation = (expression==0);
			}
			eqns.append(relation);
		}

		if(args(1).is_list() || args(1).is_cell()) {
			octave_value_list oct_vars(args(1).list_value());
			for(i=0;i<oct_vars.length();i++) {
				if(!get_symbol(oct_vars(i),expression)) {
					error("Variable %d is not a valid symbol.",i+1);
					return retval;
				}
				vars.append(expression);
			}
		} else {
			if(!get_symbol(args(1),expression)) {
				error("Variable is not a valid symbol.");
				return retval;
			}
			vars.append(expression);
		}
		sols = lsolve(eqns,vars);
		for(i=0;i<(int)sols.nops();i++) oct_sols.append(new octave_ex(sols[i].rhs()));
		retval = oct_sols;
	} catch (std::exception &e) {
		error (e.what ());
		retval = octave_value ();
	}
	return retval;
}
