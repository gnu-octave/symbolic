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
along with this program; If not, see <http://www.gnu.org/licenses/>.

*/

#include <octave/oct.h>
#include <octave/quit.h>

#include <ginac/ginac.h>
#include "ov-ex.h"
#include "symbols.h" 


DEFUN_DLD(sumterms,args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{terms} =} sumterms(@var{f})\n\
\n\
Returns a list of terms that are summed in expression @var{f}.\n\
@end deftypefn")
{
	GiNaC::ex expression;
	octave_value retval;
	octave_value_list termlist;
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
		if(GiNaC::is_a<GiNaC::add>(expression)) {
			int i, n = expression.nops();
			for(i=0;i<n;i++) {
				OCTAVE_QUIT;
				termlist.append(octave_value(new octave_ex(expression.op(i))));
			}
		} else {
			// no sum terms, return expression
			termlist.append(octave_value(new octave_ex(expression)));
		}
		retval = termlist;
	} catch (std::exception &e) {
		error (e.what ());
		retval = octave_value ();
	}

	return retval;
}
