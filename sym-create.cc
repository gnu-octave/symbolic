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
#include <octave/gripes.h>
#include <octave/defun-dld.h>
#include <octave/oct-obj.h> 
#include "ov-vpa.h" 
#include "ov-ex.h"
#include "ov-ex-mat.h" 
#include "symbols.h" 

DEFUN_DLD (vpa, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {n =} vpa(@var{s})\n\
\n\
Creates a variable precision arithmetic variable from @var{s}.\n\
@var{s} can be a scalar, vpa value, string or a ex value that \n\
is a number.\n\
@end deftypefn\n\
")
{
  octave_value retval;
  GiNaC::numeric d;
  int nargin = args.length();
  
  try 
    {
      if (nargin == 1)
	{
	  if (!get_numeric (args(0), d))
	    {
	      gripe_wrong_type_arg ("vpa", args(0));
	      return retval;
	    } 
	}
      else
	{
	  print_usage("vpa");
	  return retval;
	}

      retval = octave_value(new octave_vpa(d));
    }
  catch (std::exception &e)
    { 
      error (e.what ());
      retval = octave_value (); 
    } 
    
  return retval;
}

DEFUN_DLD (sym,args, , 
"-*- texinfo -*-\n\
Create an object of type symbol\n")
{
  octave_value retval;
  int nargin = args.length ();

  if (nargin != 1)
    {
      error("one argument expected\n");
      return octave_value ();
    }
  try 
    {
      GiNaC::symbol xtmp(args(0).string_value());
      octave_ex x(xtmp);
      retval = octave_value(new octave_ex(x));
    }
  catch (std::exception &e)
    {
      error (e.what ());
      retval = octave_value ();
    }

  return retval;
}

// an ex DLD function might be nice 

DEFUN_DLD (ex_matrix, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {n =} ex_matrix(@var{rows}, @var{cols}, ... )\n\
\n\
Creates a variable precision arithmetic variable from @var{s}.\n\
@var{s} can be a scalar, vpa value, string or a ex value that \n\
is a number.\n\
@end deftypefn\n\
")
{
  octave_value retval;
  GiNaC::ex expression;
  int nargin = args.length();
  int rows, cols,k; 

  if (nargin < 2)
    {
      print_usage("ex_matrix");
      return retval; 
    }

  if(args(0).is_real_scalar())
    {
      rows = int(args(0).double_value());
    }
  else
    {
      error("You must supply a scalar for the first argument.");
      return retval;
    }

  if(args(1).is_real_scalar())
    {
      cols = int(args(1).double_value());
    }
  else
    {
      error("You must supply a scalar for the first argument.");
      return retval;
    }

  try 
    {
      GiNaC::matrix a = GiNaC::matrix(rows,cols);
      k = 2;
      for (int i = 0; i < rows; i++)
      {
	for (int j = 0; j < cols; j++, k++)
	  {
	    if (k < nargin)
	      {
		if (!get_expression(args(k),expression))
		  {
		    error("unable to turn an argument into a symbolic expression");
		    return retval;
		  }
		a(i,j) = expression;
	      }
	    else
	      break;
	  }
      }
      retval = octave_value(new octave_ex_matrix(a));
    }
  catch (std::exception &e)
    {
      error (e.what ());
      retval = octave_value (); 
    } 
    
  return retval;
}
