
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
  catch (exception e)
    {
      e.what ();
      return retval;
    }
  return retval;
}
