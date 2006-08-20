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

*/
#include <octave/oct.h>

#ifdef NEED_OCTAVE_QUIT
#define OCTAVE_QUIT do {} while (0)
#else
#include <octave/quit.h>
#endif

#include <ginac/ginac.h>
#include "ov-vpa.h"
#include "ov-ex.h"
#include "symbols.h" 


/* Travel down the hierarchical expression and insert new symbols in the
   list so the endresult is sorted. */
static void append_symbols(octave_value_list& symlist,const GiNaC::ex& expression)
{
	int i, j, n = expression.nops();
	
	for(i=0;i<n;i++) {
		if(GiNaC::is_exactly_a<GiNaC::symbol>(expression.op(i))) {
			bool unique = true;
			int insert_here = symlist.length();
			GiNaC::ex ex_sym;
			GiNaC::symbol sym, sym_new = GiNaC::ex_to<GiNaC::symbol>(expression.op(i));
			std::string sym_name,sym_name_new = sym_new.get_name();
			for(j=0;j<symlist.length();j++) {
				OCTAVE_QUIT;
				/* have to convert back to compare: */
				get_symbol(symlist(j),ex_sym);
				sym = GiNaC::ex_to<GiNaC::symbol>(ex_sym);
				if(GiNaC::operator == (sym,sym_new)) {
					unique = false;
					break;
				} else {
					if(sym.get_name()>sym_name_new) {
						insert_here = j;
						break;
					}
				}
			}
			if(unique) {
				octave_value_list tmp = symlist;
				symlist.resize(symlist.length()+1);
				symlist(insert_here) = octave_value(new octave_ex(expression.op(i)));
				for(j=insert_here;j<tmp.length();j++)
					symlist(j+1) = tmp(j);
			}
		} else append_symbols(symlist,expression.op(i));
	}
}


DEFUN_DLD(findsymbols,args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{syms} =} findsymbols(@var{f})\n\
\n\
Returns the symbols in symbolic expression @var{f} in a list.\n\
The list is sorted in alphabetical order.\n\
@end deftypefn")
{
	GiNaC::ex expression;
	octave_value retval;
	octave_value_list symlist;
	int nargin = args.length();

	if (nargin != 1) {
		error("Need one argument.");
		return retval;
	}
	try {
		if (!get_expression (args(0), expression)) {
			error("Argument must be a symbolic expression.");
			return retval;
		}
		/* Add 1 to so this works for symbols too. */
		append_symbols(symlist,expression+1);
		retval = symlist;
	} catch (std::exception &e) {
		error (e.what ());
		retval = octave_value ();
	}

	return retval;
}
