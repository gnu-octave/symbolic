
// 2001-09-18 Paul Kienzle <pkienzle@users.sf.net>
// * use GiNaC::is_a<GiNaC::blah>(x) rather than is_ex_of_type(x, blah)
// * use GiNaC::ex_to<GiNaC::blah>(x) rather than ex_to_blah(x)

#include <octave/config.h>
#include <cstdlib>

#include <string>

class ostream;
class octave_sym;

#include <octave/lo-mappers.h>
#include <octave/lo-utils.h>
#include <octave/mx-base.h>
#include <octave/str-vec.h>

#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/oct-obj.h>
#include <octave/ops.h>
#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov.h>
#include <octave/ov-scalar.h>
#include <octave/pager.h>
#include <octave/pr-output.h>
#include <octave/symtab.h>
#include <octave/variables.h>
#include <iostream>
#include <fstream>

#include <ginac/ginac.h>

#include "ov-vpa.h"
#include "ov-ex.h"
#include "ov-sym.h"
#include "symbols.h"

bool get_expression(const octave_value arg, GiNaC::ex& expression)
{
  const octave_value& rep = (arg).get_rep();
  
  if (arg.type_id () == octave_vpa::static_type_id ())
    {
      GiNaC::numeric x = ((octave_vpa& ) rep).vpa_value();
      expression = x+0;
    }
  else if (arg.type_id () == octave_sym::static_type_id ())
    {
      GiNaC::symbol x = ((octave_sym& ) rep).sym_value();
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

bool get_symbol(const octave_value arg, GiNaC::symbol& sym)
{
  const octave_value& rep = arg.get_rep ();
     
  if (arg.type_id () == octave_sym::static_type_id ())
    sym = ((octave_sym& ) rep).sym_value();
  else if (arg.type_id () == octave_ex::static_type_id ())
    {
      GiNaC::ex x = ((octave_ex& ) rep).ex_value();
      if(GiNaC::is_a<GiNaC::symbol>(x))
	sym = GiNaC::ex_to<GiNaC::symbol>(x);
      else
	return false;
    }
  else
    return false;

  return true; 
}

bool get_numeric(const octave_value arg, GiNaC::numeric& number)
{
  const octave_value& rep = arg.get_rep ();

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

DEFUN_DLD(symbols,args,,"Initialize symbolic manipulation")
{
  octave_value retval;
  install_ex_type();
  install_sym_type();
  install_vpa_type();
  install_ex_ops();
  install_sym_ops();
  install_vpa_ops();
  return retval;
}

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
      print_usage("to_double");
      return retval;
    }

  if (!get_numeric (args(0), num))
    {
      print_usage("to_double");
      return retval;
    }

  retval = octave_value(num.to_double ());

  return retval;
}

DEFUN_DLD(digits, args, , 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{dgts} =} digits([@var{num}])\n\
Change the precision for the vpa type
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
  
  if(nargin == 1)
    {
      if(args(0).is_real_scalar())
	{
	  GiNaC::Digits = int(args(0).double_value());
	}
      else
	{
	  print_usage("digits");
	}
    }

  double dig = double(GiNaC::Digits);
  retval = octave_value(dig);
  return(retval);
}

DEFUN_DLD(Pi,args, ,
"-*- texinfo -*-\n\
Pi evaluated to the current value of Digits\n\
\n\
@seealso{digits}")
{
  return octave_value(new octave_vpa(GiNaC::ex_to_numeric(GiNaC::Pi.evalf())));
}

DEFUN_DLD(is_vpa, args, ,
"Return true if an object is of type vpa, false otherwise.\n")
{
  bool retval;
  retval = (args(0).type_id() == octave_vpa::static_type_id());
  return octave_value(retval);
}

DEFUN_DLD (sym,args, , 
"-*- texinfo -*-\n\
Create an object of type symbol\n")
{
  int nargin = args.length ();

  if (nargin != 1)
    {
      error("one argument expected\n");
      return octave_value ();
    }

  GiNaC::symbol xtmp(args(0).string_value());
  octave_sym x(xtmp);
  return octave_value(new octave_sym(x));
}

DEFUN_DLD(is_sym,args, ,"Return true if an object is of type sym false otherwise.\n")
{
  bool retval;
  retval = (args(0).type_id() == octave_sym::static_type_id());
  return octave_value(retval);
}

DEFUN_DLD(differentiate,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {da_dx =} differentiate(@var{a},@var{x} [, @var{n}])\n\
\n\
Return the @var{n}th derivative of @var{a} with respect to @var{x}. If @var{n} is not\n\
supplied then a default value of 1 is used.\n\
@end deftypefn")
{
  GiNaC::ex expression;
  GiNaC::symbol variable;
  GiNaC::numeric num;
  int order;
  octave_value retval;
  int nargin = args.length();

  if ((nargin < 2) || (nargin > 3))
    {
      print_usage ("differentiate");
      return retval;
    }
 
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

  return octave_value(new octave_ex(expression.diff(variable,order)));
}

DEFINE_EX_GINAC_FUNCTION(Cos,cos,"cosine");
DEFINE_EX_GINAC_FUNCTION(Sin,sin,"sine");
DEFINE_EX_GINAC_FUNCTION(Tan,tan,"tangent");
DEFINE_EX_GINAC_FUNCTION(aCos,acos,"inverse cosine");
DEFINE_EX_GINAC_FUNCTION(aSin,asin,"inverse sine");
DEFINE_EX_GINAC_FUNCTION(aTan,atan,"inverse tangent");
DEFINE_EX_GINAC_FUNCTION(Cosh,cosh,"hyperbolic cosine");
DEFINE_EX_GINAC_FUNCTION(Sinh,sinh,"hyperbolic sine");
DEFINE_EX_GINAC_FUNCTION(Tanh,tanh,"hyperbolic tangent");
DEFINE_EX_GINAC_FUNCTION(aCosh,acosh,"inverse hyperbolic cosine");
DEFINE_EX_GINAC_FUNCTION(aSinh,asinh,"inverse hyperbolic sine");
DEFINE_EX_GINAC_FUNCTION(aTanh,atanh,"inverse hyperbolic tangent");
DEFINE_EX_GINAC_FUNCTION(Exp,exp,"exponential");
DEFINE_EX_GINAC_FUNCTION(Log,log,"logarithm");
DEFINE_EX_GINAC_FUNCTION(Abs,abs,"absolute value");

DEFINE_EX_SYM_GINAC_FUNCTION(degree, degree,"degree");
DEFINE_EX_SYM_GINAC_FUNCTION(ldegree, ldegree,"low degree");
DEFINE_EX_SYM_GINAC_FUNCTION(tcoeff, tcoeff, "trailing coeffiecient");
DEFINE_EX_SYM_GINAC_FUNCTION(lcoeff, lcoeff, "leading coefficient");

DEFINE_EX_EX_SYM_GINAC_FUNCTION(quotient,quo,"quotient");
DEFINE_EX_EX_SYM_GINAC_FUNCTION(remainder,rem,"remainder");
DEFINE_EX_EX_SYM_GINAC_FUNCTION(premainder,prem,"pseudo-remainder");

DEFUN_DLD(is_ex,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {bool =} is_ex(@var{a})\n\
\n\
Return true if an object is of type ex.\n\
@seealso{is_sym, is_vpa}")
{
  bool retval;
  retval = (args(0).type_id() == octave_ex::static_type_id());
  return octave_value(retval);
}

DEFUN_DLD(subs,args,,
"-*- texinfo -*-\n\
@deftypefn Loadable Function {b =} subs(@var{a},@var{x},@var{n})\n\
\n\
Substitute a number for a variables in an expression\n\
@table @var\n\
@item a\n\
 The expresion in which the substition will occur.\n\
@item x\n\
 The variable that will be substituted.\n\
@item n\n\
 The expression,vpa value or scalar that will replace x.\n\
@end table\n\
\n\
@end deftypefn\n\
")
{
  GiNaC::ex expression;
  GiNaC::symbol the_sym;
  GiNaC::ex ex_sub;
  GiNaC::ex tmp;
  int nargin = args.length ();
  octave_value retval;

  if (nargin != 3)
    {
      error("need three arguments\n");
      return retval;
    }

  try 
    {
      if (!get_expression (args(0), expression))
	{
	  gripe_wrong_type_arg ("subs",args(0));
	  return retval;
	}

      if (!get_symbol (args(1), the_sym))
	{
	  gripe_wrong_type_arg("subs",args(1));
	  return retval;
	}

      if (!get_expression (args(2), ex_sub))
	{
	  gripe_wrong_type_arg ("subs",args(2));
	  return retval;
	}

      tmp = expression.subs(the_sym == ex_sub);
      retval = octave_value (new octave_ex(tmp));
    }
  catch (exception e)
    {
      e.what ();
      return octave_value ();
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
      print_usage("expand");
      return retval;
    }
  if(args(0).type_id() == octave_ex::static_type_id())
    {
      const octave_value& rep1 = args(0).get_rep();
      expression = ((const octave_ex& ) rep1).ex_value();
    }
  else
    {
      gripe_wrong_type_arg("expand",args(0));
    }

  result = expression.expand();
  return octave_value(new octave_ex(result));
}

DEFUN_DLD(coeff,args,,
"-*- texinfo -*-
@deftypefn {Loadable Function} {b =} coeff(@var{a},@var{x},@var{n})\n\
\n\
Obtain the @var{n}th coefficient of the variable @var{x} in @var{a}.  
\n\
@end deftypefn\n\
")
{
  octave_value retval;
  GiNaC::ex expression;
  GiNaC::symbol sym;
  int n;

  if(args.length () != 3)
    {
      print_usage("coeff");
      return retval;
    }

  if(args(0).type_id() == octave_ex::static_type_id())
    {
      const octave_value& rep0 = args(0).get_rep();
      expression = ((const octave_ex& ) rep0).ex_value();
    }
  else
    {
      gripe_wrong_type_arg("coeff",args(0));
      return retval;
    }

  if(args(1).type_id() == octave_sym::static_type_id())
    {
      const octave_value& rep1 = args(1).get_rep();
      sym = ((const octave_sym& ) rep1).sym_value();
    }
  else
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
  GiNaC::symbol the_sym;

  if(args.length() != 2)
    {
      print_usage("collect");
      return retval;
    }

  if(args(0).type_id() == octave_ex::static_type_id())
    {
      const octave_value& rep1 = args(0).get_rep();
      expression = ((const octave_ex& ) rep1).ex_value();
    }
  else
    {
      gripe_wrong_type_arg("collect",args(0));
    }

  if(args(1).type_id() == octave_sym::static_type_id())
    {
      const octave_value& rep2 = args(1).get_rep();
      the_sym = ((octave_sym& ) rep2).sym_value();
    }
  else
    {
      gripe_wrong_type_arg("collect",args(1));
    }

  retval = new octave_ex(expression.collect(the_sym));

  return retval;
}


