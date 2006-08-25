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

// 2001-09-18 Paul Kienzle <pkienzle@users.sf.net>
// * use GiNaC::is_a<GiNaC::blah>(x) rather than is_ex_of_type(x, blah)
// * use GiNaC::ex_to<GiNaC::blah>(x) rather than ex_to_blah(x)
// 2003-04-19 Willem Atsma <watsma@users.sf.net>
// * added get_relational()

#include <octave/config.h>
#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/oct-obj.h>
#include <octave/pager.h>
#include <octave/quit.h>

#include <ginac/ginac.h>
#include "ov-vpa.h"
#include "ov-ex.h"
#include "ov-ex-mat.h"
#include "ov-relational.h"
#include "sym-ops.h"
#include "symbols.h"

bool get_expression(const octave_value arg, GiNaC::ex& expression)
{
  const OV_REP_TYPE& rep = (arg).get_rep();

  if (arg.type_id () == octave_vpa::static_type_id ())
    {
      GiNaC::numeric x = ((octave_vpa& ) rep).vpa_value();
      expression = x+0;
    }
  else if (arg.type_id () == octave_ex::static_type_id ())
    {
      GiNaC::ex x = ((octave_ex& ) rep).ex_value();
      expression = x;
    }
  else if (arg.is_real_scalar ())
    {
      GiNaC::numeric x(arg.double_value ());
      expression = x+0;
    }
  else 
    {
      return false;
    }

  return true;
}

bool get_symbol(const octave_value arg, GiNaC::ex& sym)
{
  const OV_REP_TYPE& rep = arg.get_rep ();
  GiNaC::ex x; 
  if (arg.type_id () == octave_ex::static_type_id ())
    x = ((octave_ex& ) rep).ex_value();
  else
    return false;

  if (GiNaC::is_a<GiNaC::symbol>(x))
    sym = x;
  else
    return false;

  return true; 
}

bool get_numeric(const octave_value arg, GiNaC::numeric& number)
{
  const OV_REP_TYPE& rep = arg.get_rep ();

  if (arg.type_id () == octave_ex::static_type_id ())
    {
      GiNaC::ex x = ((octave_ex& ) rep).ex_value();
      if(GiNaC::is_a<GiNaC::numeric>(x))
	number = GiNaC::ex_to<GiNaC::numeric>(x);
      else
	return false;
    }
  else if (arg.type_id () == octave_vpa::static_type_id ())
    number = ((const octave_vpa &) rep).vpa_value ();
  else if (arg.is_real_scalar ())
    number = GiNaC::numeric (arg.double_value ());
  else if (arg.is_string ())
    number = GiNaC::numeric (arg.string_value ().c_str ());
  else
    return false;

  return true;
}

bool get_relation(const octave_value arg, GiNaC::relational& relation)
{
	const OV_REP_TYPE& rep = arg.get_rep();
	if (arg.type_id () == octave_relational::static_type_id ()) {
		GiNaC::relational x = ((octave_relational& ) rep).relational_value();
		relation = x;
	} else return false;
	
	return true;
}

DEFUN_DLD(symbols,args,,"Initialize symbolic manipulation")
{
  octave_value retval;
  octave_vpa::register_type ();
  octave_ex::register_type (); 
  octave_ex_matrix::register_type ();
  octave_relational::register_type (); 

  install_ex_matrix_ops();
  install_ex_ops();
  install_vpa_ops();
  return retval;
}

DEFUN_DLD(to_double,args, , 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {d =} to_double(@var{n})\n\
\n\
Convert a vpa, string, ex or string type to a double.\n\
\n\
@end deftypefn\n\
")
{
  octave_value retval;
  int nargin = args.length();
  GiNaC::numeric num;

  if (nargin != 1)
    {
      print_usage ();
      return retval;
    }

  try 
    {
      if (!get_numeric (args(0), num))
	{
	  print_usage ();
	  return retval;
	}
      
      retval = octave_value(num.to_double ());
    }
  catch (std::exception &e)
    { 
      error (e.what ());
      retval = octave_value (); 
    } 

  return retval;
}

DEFUN_DLD(digits, args, , 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{dgts} =} digits([@var{num}])\n\
Change the precision for the vpa type\n\
@end deftypefn\n\
")
{
  octave_value retval;
  int nargin = args.length();
 
  if ((nargin != 1) && (nargin != 0))
    {
      error("you must supply 0 or 1 arguments\n");
      return(retval);
    }

  try 
    {     
      if(nargin == 1)
	{
	  if(args(0).is_real_scalar())
	    {
	      GiNaC::Digits = int(args(0).double_value());
	    }
	  else
	    {
	      print_usage ();
	    }
	}

      double dig = double(GiNaC::Digits);
      retval = octave_value(dig);

    }
  catch (std::exception &e)
    { 
      error (e.what ());
      retval = octave_value (); 
    } 

  return(retval);
}

DEFUN_DLD(Pi,args, ,
"-*- texinfo -*-\n\
Pi evaluated to the current value of Digits\n\
\n\
@seealso{digits}")
{
  octave_value retval; 
  try 
    {
      retval = octave_value(new octave_vpa(GiNaC::ex_to<GiNaC::numeric>(GiNaC::Pi.evalf())));
    }
  catch (std::exception &e)
    {
      error (e.what ());
      retval = octave_value (); 
    }

  return retval;
}


DEFUN_DLD_EX_GINAC_FUNCTION(Sqrt,sqrt,"square root");
DEFUN_DLD_EX_GINAC_FUNCTION(Cos,cos,"cosine");
DEFUN_DLD_EX_GINAC_FUNCTION(Sin,sin,"sine");
DEFUN_DLD_EX_GINAC_FUNCTION(Tan,tan,"tangent");
DEFUN_DLD_EX_GINAC_FUNCTION(aCos,acos,"inverse cosine");
DEFUN_DLD_EX_GINAC_FUNCTION(aSin,asin,"inverse sine");
DEFUN_DLD_EX_GINAC_FUNCTION(aTan,atan,"inverse tangent");
DEFUN_DLD_EX_GINAC_FUNCTION(Cosh,cosh,"hyperbolic cosine");
DEFUN_DLD_EX_GINAC_FUNCTION(Sinh,sinh,"hyperbolic sine");
DEFUN_DLD_EX_GINAC_FUNCTION(Tanh,tanh,"hyperbolic tangent");
DEFUN_DLD_EX_GINAC_FUNCTION(aCosh,acosh,"inverse hyperbolic cosine");
DEFUN_DLD_EX_GINAC_FUNCTION(aSinh,asinh,"inverse hyperbolic sine");
DEFUN_DLD_EX_GINAC_FUNCTION(aTanh,atanh,"inverse hyperbolic tangent");
DEFUN_DLD_EX_GINAC_FUNCTION(Exp,exp,"exponential");
DEFUN_DLD_EX_GINAC_FUNCTION(Log,log,"logarithm");
DEFUN_DLD_EX_GINAC_FUNCTION(Abs,abs,"absolute value");

DEFUN_DLD_EX_SYM_GINAC_FUNCTION(degree, degree,"degree");
DEFUN_DLD_EX_SYM_GINAC_FUNCTION(ldegree, ldegree,"low degree");
DEFUN_DLD_EX_SYM_GINAC_FUNCTION(tcoeff, tcoeff, "trailing coeffiecient");
DEFUN_DLD_EX_SYM_GINAC_FUNCTION(lcoeff, lcoeff, "leading coefficient");

DEFUN_DLD_EX_EX_SYM_GINAC_FUNCTION(quotient,quo,"quotient");
DEFUN_DLD_EX_EX_SYM_GINAC_FUNCTION(remainder,rem,"remainder");
DEFUN_DLD_EX_EX_SYM_GINAC_FUNCTION(premainder,prem,"pseudo-remainder");

DEFUN_DLD(subs,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {b =} subs(@var{a},@var{x},@var{n})\n\
\n\
Substitute variables in an expression.\n\
@table @var\n\
@item a\n\
 The expresion in which the substition will occur.\n\
@item x\n\
 The variables that will be substituted.\n\
@item n\n\
 The expressions, vpa values or scalars that will replace @var{x}.\n\
@end table\n\
\n\
Multiple substitutions can be made by using lists or cell-arrays for\n\
@var{x} and @var{n}.\n\
\n\
Examples:\n\
@example\n\
symbols\n\
x=sym(\"x\"); y=sym(\"y\"); f=x^2+3*x*y-y^2;\n\
v = subs (f,x,1)\n\
w = subs (f,@{x,y@},@{1,vpa(1/3)@})\n\
@end example\n\
\n\
@end deftypefn\n\
")
{
	GiNaC::ex expression;
	GiNaC::ex the_sym;
	GiNaC::ex ex_sub;
	GiNaC::ex tmp;
	int nargin = args.length ();
	octave_value retval;

	if (nargin != 3) {
		error("need three arguments\n");
		return retval;
	}

	try {
		if (!get_expression (args(0), expression)) {
			gripe_wrong_type_arg ("subs",args(0));
			return retval;
		}
		if (!(args(1).is_list() || args(1).is_cell())) {
			if (!get_symbol (args(1), the_sym)) {
				gripe_wrong_type_arg("subs",args(1));
				return retval;
			}
			if (!get_expression (args(2), ex_sub)) {
				gripe_wrong_type_arg ("subs",args(2));
				return retval;
			}
			tmp = expression.subs(the_sym == ex_sub);
		} else {
			octave_value_list symlist, sublist;
			int i;
			symlist = args(1).list_value();
			sublist = args(2).list_value();
			if(symlist.length()!=sublist.length()) {
				error("Number of expressions and substitutes must be the same.");
				return retval;
			}
			tmp = expression;
			for(i=0;i<symlist.length();i++) {
				OCTAVE_QUIT;
				if (!get_symbol (symlist(i),the_sym)) {
					gripe_wrong_type_arg("subs",symlist(i));
					return retval;
				}
				if (!get_expression (sublist(i),ex_sub)) {
					gripe_wrong_type_arg("subs",sublist(i));
					return retval;
				}
				tmp = tmp.subs(the_sym == ex_sub);
			}
		}
		retval = octave_value (new octave_ex(tmp));
	} catch (std::exception &e) {
		error (e.what ());
		retval = octave_value ();
	}

	return retval;
}

DEFUN_DLD(expand,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {b =} expand(@var{a})\n\
\n\
Expand an expression\n\
@table @var\n\
@item a\n\
 The expresion in which the expansion will occur.\n\
@end table\n\
\n\
@end deftypefn\n\
")
{
  GiNaC::ex expression;
  GiNaC::symbol the_sym;
  GiNaC::ex result;
  octave_value retval;

  if(args.length() != 1)
    {
      print_usage ();
      return retval;
    }

  try 
    {

      if(args(0).type_id() == octave_ex::static_type_id())
	{
	  const OV_REP_TYPE& rep1 = args(0).get_rep();
	  expression = ((const octave_ex& ) rep1).ex_value();
	}
      else
	{
	  gripe_wrong_type_arg("expand",args(0));
	}
      
      result = expression.expand();
      retval = octave_value(new octave_ex(result));
    }
  catch (std::exception &e)
    {
      error (e.what ());
      retval = octave_value ();
    }
  
  return retval;
}


DEFUN_DLD(coeff,args,,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {b =} coeff(@var{a},@var{x},@var{n})\n\
\n\
Obtain the @var{n}th coefficient of the variable @var{x} in @var{a}.\n\
\n\
@end deftypefn\n\
")
{
  octave_value retval;
  GiNaC::ex expression;
  GiNaC::ex sym;
  int n;

  if(args.length () != 3)
    {
      print_usage ();
      return retval;
    }

  try 
    {
      if(!get_expression(args(0), expression))
	{
	  gripe_wrong_type_arg("coeff",args(0));
	  return retval;
	}

      if(!get_symbol (args(1), sym))
	{
	  gripe_wrong_type_arg("coeff",args(1));
	  return retval;
	}

      if(args(2).is_real_scalar())
	{
	  n = (int )args(2).double_value();
	}
      else
	{
	  gripe_wrong_type_arg("coeff",args(2));
	  return retval;
	}

      retval = octave_value (new octave_ex (expression.coeff(sym,n)));
    }
  catch (std::exception &e)
    {
      error (e.what ());
      retval = octave_value ();
    } 

  return retval;
}

DEFUN_DLD(collect,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {b =} collect(@var{a},@var{x})\n\
\n\
collect the terms in @var{a} as a univariate polynomial in @var{x}\n\
@table @var\n\
@item a\n\
 The expresion in which the collection will occur.\n\
@item x\n\
 The variable that will be collected.\n\
@end table\n\
\n\
@end deftypefn\n\
")
{
  octave_value retval;
  GiNaC::ex expression;
  GiNaC::ex the_sym;

  if(args.length() != 2)
    {
      print_usage ();
      return retval;
    }

  try 
    {
      if(!get_expression(args(0), expression))
	{
	  gripe_wrong_type_arg("collect",args(0));
	}
      
      if(!get_symbol(args(1), the_sym))
	{
	  gripe_wrong_type_arg("collect",args(1));
	}

      retval = new octave_ex(expression.collect(the_sym));

    }
  catch (std::exception &e)
    {
      error (e.what ()); 
      retval = octave_value (); 
    }

  return retval;
}

DEFUN_DLD(Gcd,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {b =} collect(@var{a},@var{x})\n\
\n\
Collect the terms in @var{a} as a univariate polynomial in @var{x}\n\
@table @var\n\
@item a\n\
 The expresion in which the collection will occur.\n\
@item x\n\
 The variable that will be collected.\n\
@end table\n\
\n\
@end deftypefn\n\
")
{
  octave_value retval;
  GiNaC::ex expression;
  GiNaC::ex the_sym;

  if(args.length() != 2)
    {
      print_usage ();
      return retval;
    }

  if(!get_expression(args(0), expression))
    {
      gripe_wrong_type_arg("collect",args(0));
    }

  if(!get_symbol(args(0), the_sym))
    {
      gripe_wrong_type_arg("collect",args(1));
    }

  retval = new octave_ex(expression.collect(GiNaC::ex_to<GiNaC::symbol>(the_sym)));

  return retval;
}
