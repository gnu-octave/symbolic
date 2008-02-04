/*

Copyright (C) 2002 Ben Sapp

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


#include <octave/config.h>
#include <octave/defun-dld.h>
#include <octave/oct-obj.h> 
#include "ov-vpa.h" 
#include "ov-ex.h"
#include "ov-ex-mat.h" 

DEFUN_DLD(is_vpa, args, ,
"Return true if an object is of type vpa, false otherwise.\n")
{
  bool retval;
  retval = (args(0).type_id() == octave_vpa::static_type_id());
  return octave_value(retval);
}

DEFUN_DLD(is_sym,args, ,"Return true if an object is of type sym false otherwise.\n")
{
  bool retval;
  const OV_REP_TYPE& rep = args(0).get_rep();

  retval = args(0).type_id () == octave_ex::static_type_id () &&
	    GiNaC::is_a<GiNaC::symbol>(((octave_ex& ) rep).ex_value ());
  return octave_value(retval);
}


DEFUN_DLD(is_ex,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {bool =} is_ex(@var{a})\n\
\n\
Return true if an object is a symbolic expression.\n\
@seealso{is_vpa, is_sym, is_ex_matrix}\n\
@end deftypefn")
{
  bool retval;
  retval = (args(0).type_id() == octave_ex::static_type_id());
  return octave_value(retval);
}


DEFUN_DLD(is_ex_matrix,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {bool =} is_ex_matrix(@var{a})\n\
\n\
Return true if an object is a symbolic matrix.\n\
@seealso{is_vpa, is_sym, is_ex}\n\
@end deftypefn")
{
  bool retval;
  retval = (args(0).type_id() == octave_ex_matrix::static_type_id());
  return octave_value(retval);
}
