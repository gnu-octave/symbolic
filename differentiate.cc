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
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
#include <octave/config.h>
#include <octave/defun-dld.h>
#include <octave/oct-obj.h>
#include <ginac/ginac.h>
#include "ov-vpa.h"
#include "ov-ex.h"
#include "symbols.h" 


DEFUN_DLD(differentiate,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {da_dx =} differentiate(@var{a},@var{x} [, @var{n}])\n\
\n\
Return the @var{n}th derivative of @var{a} with respect to @var{x}. If @var{n} is not\n\
supplied then a default value of 1 is used.\n\
@end deftypefn")
{
  GiNaC::ex expression;
  GiNaC::ex variable;
  GiNaC::numeric num;
  int order;
  octave_value retval;
  int nargin = args.length();

  if ((nargin < 2) || (nargin > 3))
    {
      print_usage ("differentiate");
      return retval;
    }
  try 
    { 
      if (!get_expression (args(0), expression))
	{
	  print_usage ("differentiate");
	  return retval;
	}
      
      if (!get_symbol (args(1), variable))
	{
	  print_usage ("differentiate");
	  return retval;
	}
      
      if (nargin == 3)
	{
	  if (!get_numeric (args(2), num))
	    {
	      print_usage ("differentiate");
	      return retval;
	    }
	  order = int(num.to_double ());
	  if (order < 0)
	    {
	      error("must supply an integer greater than zero\n");
	      return retval;
	    }
	}
      else
	order = 1;

      retval = octave_value(new octave_ex
			    (expression.diff
			     (GiNaC::ex_to<GiNaC::symbol>(variable),order)));
    }
  catch (std::exception &e)
    {
      error (e.what ());
      retval = octave_value ();
    }

  return retval;
}
