bool get_expression(const octave_value arg, GiNaC::ex& expression);
bool get_symbol(const octave_value arg, GiNaC::ex& sym);
bool get_numeric(const octave_value arg, GiNaC::numeric& number);

#define DEFUN_DLD_EX_GINAC_FUNCTION(oct_name,ginac_name,description) \
DEFUN_DLD(oct_name, args, , \
"-*- texinfo -*-\n\
@deftypefn Loadable Function {r =}" # oct_name "(@var{x})\n\
Return the " description " of a symbolic expression.\n\
@end deftypefn\n\
") \
{ \
  int nargin = args.length (); \
  octave_value retval; \
  octave_ex *r = NULL; \
  GiNaC::ex expression; \
 \
  if (nargin != 1) \
    { \
      print_usage(# oct_name); \
      return retval; \
    } \
 \
  try \
   { \
      if(!get_expression(args(0), expression)) \
        { \
          print_usage(# oct_name); \
          return retval; \
        } \
 \
      r = new octave_ex(GiNaC::ginac_name (expression)); \
      retval = octave_value (r); \
    } \
  catch (std::exception &e) \
    { \
      error (e.what ()); \
      retval = octave_value (); \
    } \
 \
  return retval; \
}

#define DEFUN_DLD_EX_SYM_GINAC_FUNCTION(oct_name,ginac_name,description) \
DEFUN_DLD(oct_name, args, , \
"-*- texinfo -*-\n\
@deftypefn Loadable Function {r =}" # oct_name "(@var{a}, @var{x})\n\
Return the " description " of a symbolic expression.\n\
@end deftypefn\n\
") \
{ \
  int nargin = args.length (); \
  octave_value retval; \
  octave_ex *r = NULL; \
  GiNaC::ex expression; \
  GiNaC::ex sym; \
 \
  if (nargin != 2) \
    { \
      error("need exactly two arguments"); \
      return retval; \
    } \
 \
  try \
    { \
      if(!get_expression(args(0), expression)) \
        { \
          print_usage(# oct_name); \
          return retval; \
        } \
 \
      if (!get_symbol(args(1), sym)) \
        { \
          print_usage(# oct_name); \
          return retval; \
        } \
 \
      r = new octave_ex(expression.ginac_name \
			(GiNaC::ex_to<GiNaC::symbol>(sym))); \
 \
    } \
  catch (std::exception &e) \
    { \
      octave_value_list empty; \
      error (e.what ()); \
      return empty; \
    } \
 \
  return octave_value(r); \
}

#define DEFUN_DLD_EX_EX_SYM_GINAC_FUNCTION(oct_name,ginac_name,description) \
DEFUN_DLD(oct_name, args, , \
"-*- texinfo -*-\n\
@deftypefn Loadable Function {r =}" # oct_name "(@var{a}, @var{x})\n\
Return the " description " of a symbolic expression.\n\
@end deftypefn\n\
") \
{ \
  int nargin = args.length (); \
  octave_value retval; \
  octave_ex *r = NULL; \
  GiNaC::ex expression0; \
  GiNaC::ex expression1; \
  GiNaC::ex sym; \
 \
  if (nargin != 3) \
    { \
      error("need exactly three arguments"); \
      return retval; \
    } \
 \
  try \
    { \
      if(!get_expression(args(0), expression0)) \
        { \
          gripe_wrong_type_arg(# oct_name, args(0)); \
          print_usage(# oct_name); \
          return retval; \
        } \
 \
      if(!get_expression(args(1), expression1)) \
        { \
          gripe_wrong_type_arg(# oct_name, args(1)); \
          print_usage(# oct_name); \
          return retval; \
        } \
 \
      if (!get_symbol(args(2), sym)) \
        { \
          gripe_wrong_type_arg(# oct_name, args(2)); \
          print_usage(# oct_name); \
          return retval; \
        } \
 \
      r = new octave_ex(ginac_name (expression0, \
				    expression1, \
				    GiNaC::ex_to<GiNaC::symbol>(sym) )); \
 \
    } \
  catch (std::exception &e) \
    { \
      octave_value_list empty; \
      error (e.what ()); \
      return empty; \
    }\
 \
  return octave_value(r); \
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
