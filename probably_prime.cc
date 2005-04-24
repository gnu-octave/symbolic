## Copyright (C) 2001 Paul Kienzle
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#include <octave/oct.h>
#include <ginac/ginac.h>
#include "symbols.h"


DEFUN_DLD(probably_prime, args, ,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {r =} is_prime(@var{x})\n\
Return true if the variable precision number is probably prime,\n\
with error 1 in 2^100.\n\
@end deftypefn\n\
")
{
  int nargin = args.length ();
  octave_value_list retval; 
  GiNaC::numeric value;

  if (nargin != 1)
    {
      print_usage("probably_prime");
      return retval;
    }

  try
   {
      if(!get_numeric(args(0), value))
        {
          print_usage("probably_prime");
          return retval;
        }
      retval(0) = GiNaC::is_prime(value);
   }
  catch (std::exception &e)
    {
      error (e.what ());
      return retval;
    }
  return retval;
}
