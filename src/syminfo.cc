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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

*/

#include <octave/oct.h>
#include <ginac/ginac.h>
#include "ov-ex.h"
#include "ov-relational.h"
#include "ov-struct.h"
#include "ov-bool.h"
#include "symbols.h" 


inline static void
add_info_field(Octave_map& info,const GiNaC::ex& exp,std::string field,int info_flag)
{
	bool flag = exp.info(info_flag);
	info.assign(field,octave_value(flag));
}

static void get_info(Octave_map& oct_info, const GiNaC::ex& gobj)
{
	add_info_field(oct_info,gobj,"numeric",GiNaC::info_flags::numeric);
	add_info_field(oct_info,gobj,"real",GiNaC::info_flags::real);
	add_info_field(oct_info,gobj,"rational",GiNaC::info_flags::rational);
	add_info_field(oct_info,gobj,"integer",GiNaC::info_flags::integer);
	add_info_field(oct_info,gobj,"crational",GiNaC::info_flags::crational);
	add_info_field(oct_info,gobj,"cinteger",GiNaC::info_flags::cinteger);
	add_info_field(oct_info,gobj,"relation",GiNaC::info_flags::relation);
	add_info_field(oct_info,gobj,"symbol",GiNaC::info_flags::symbol);
	add_info_field(oct_info,gobj,"list",GiNaC::info_flags::list);
	add_info_field(oct_info,gobj,"exprseq",GiNaC::info_flags::exprseq);
	add_info_field(oct_info,gobj,"polynomial",GiNaC::info_flags::polynomial);
	add_info_field(oct_info,gobj,"integer_polynomial",GiNaC::info_flags::integer_polynomial);
	add_info_field(oct_info,gobj,"cinteger_polynomial",GiNaC::info_flags::cinteger_polynomial);
	add_info_field(oct_info,gobj,"rational_polynomial",GiNaC::info_flags::rational_polynomial);
	add_info_field(oct_info,gobj,"crational_polynomial",GiNaC::info_flags::crational_polynomial);
	add_info_field(oct_info,gobj,"rational_function",GiNaC::info_flags::rational_function);
	add_info_field(oct_info,gobj,"algebraic",GiNaC::info_flags::algebraic);
	add_info_field(oct_info,gobj,"indexed",GiNaC::info_flags::indexed);
	add_info_field(oct_info,gobj,"has_indices",GiNaC::info_flags::has_indices);
	add_info_field(oct_info,gobj,"idx",GiNaC::info_flags::idx);
}

DEFUN_DLD(syminfo,args,nargout,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {@var{info} =} syminfo(@var{eqn})\n\
\n\
Returns information regarding the nature of symbolic expression @var{eqn} in\n\
a structure. Uses the GiNaC::info() function.\n\
@end deftypefn")
{
	Octave_map oct_info;
	octave_value retval;
	int nargin = args.length();
	
	if (nargin != 1) {
		error("Wrong number of arguments.");
		return retval = oct_info;
	}
	
	try {
		GiNaC::ex expression;
		if(!get_expression(args(0),expression)) {
			GiNaC::numeric num;
			if(get_numeric(args(0),num))
				expression = GiNaC::ex(num);
			else {
				GiNaC::relational relation;
				if(get_relation(args(0),relation)) {
					expression = GiNaC::ex(relation);
					std::cout << expression << std::endl;
				} else {
					if(!get_symbol(args(0),expression)) {
						error("Expected a symbolic object as parameter.");
						return retval = oct_info;
					}
				}
			}
		}
		get_info(oct_info,expression);
		retval = oct_info;
	} catch (std::exception &e) {
		error (e.what ());
		retval = octave_value ();
	}
	return retval;
}
