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

#include <ginac/ginac.h>
#include "ov-vpa.h"
#include "ov-ex.h"
#include "symbols.h" 


DEFUN_DLD(numden,args,nargout,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {[num,den] =} numden(@var{f})\n\
\n\
Return the numerator and denominator of symbolic expression @var{f}.\n\
@end deftypefn")
{
	GiNaC::ex expression, numden_list;
	octave_value_list retval;
	int nargin = args.length();
	if (nargin != 1) {
		print_usage ("numden");
		return retval;
	}
	try { 
		if (!get_expression (args(0), expression)) {
			error("Argument must be a symbolic expression.");
			return retval;
		}
		numden_list = expression.numer_denom();
		retval.append(new octave_ex(numden_list[0]));
		retval.append(new octave_ex(numden_list[1]));
	} catch(std::exception &e) {
		error (e.what ());
		retval = octave_value ();
	}
	return retval;
}
