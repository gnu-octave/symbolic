/*
Copyright (C) 2000 Benjamin Sapp

This is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You can have receive a copy of the GNU General Public License.  Write 
to the Free Software Foundation, 59 Temple Place - Suite 330, 
Boston, MA  02111-1307, USA.
*/

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
#include "ov-ex.h"
#include "ov-sym.h"
#include "ov-vpa.h"

#ifdef DEFUNOP_OP
#undef DEFUNOP_OP
#endif

#define DEFUNOP_OP(name, t, op) \
  UNOPDECL (name, a) \
  { \
    CAST_UNOP_ARG (const octave_ ## t&); \
    return octave_value (new octave_ex (op v.t ## _value ())); \
  }

DEFUNOP_OP (uminus, ex, -)

DEFNCUNOP_METHOD (incr, ex, increment)
DEFNCUNOP_METHOD (decr, ex, decrement)

#ifdef DEFBINOP_OP
#undef DEFBINOP_OP
#endif

#define DEFBINOP_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    return octave_value \
      (new octave_ex (v1.t1 ## _value () op v2.t2 ## _value ())); \
  }

#ifdef DEFBINOP_POW
#undef DEFBINOP_POW
#endif

#define DEFBINOP_POW(name, t1, t2) \
  BINOPDECL(name, a1, a2) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    return octave_value \
      (new octave_ex (pow(v1.t1 ## _value (), v2.t2 ## _value ()))); \
  }

// Addition operations
DEFBINOP_OP(ex_scalar_add,ex,scalar,+)
DEFBINOP_OP(scalar_ex_add,scalar,ex,+)
DEFBINOP_OP(ex_vpa_add,ex,vpa,+)
DEFBINOP_OP (add, ex, ex, +)
DEFBINOP_OP(ex_sym_add,ex,sym,+)

// Subtraction operations
DEFBINOP_OP(ex_scalar_sub,ex,scalar,-)
DEFBINOP_OP(scalar_ex_sub,scalar,ex,-)
DEFBINOP_OP(ex_vpa_sub,ex,vpa,-)
DEFBINOP_OP (sub, ex, ex, -)
DEFBINOP_OP(ex_sym_sub,ex,sym,-)

// Multiplication operations
DEFBINOP_OP(ex_scalar_mul,ex,scalar,*)
DEFBINOP_OP(scalar_ex_mul,scalar,ex,*)
DEFBINOP_OP(ex_vpa_mul,ex,vpa,*)
DEFBINOP_OP (mul, ex, ex, *)
DEFBINOP_OP(ex_sym_mul,ex,sym,*)

// Division operations
DEFBINOP_OP(ex_scalar_div,ex,scalar,/)
DEFBINOP_OP(scalar_ex_div,scalar,ex,/)
DEFBINOP_OP(ex_vpa_div,ex,vpa,/)
DEFBINOP_OP (div, ex, ex, /)
DEFBINOP_OP(ex_sym_div,ex,sym,/)

// Power operations 
DEFBINOP_POW(pow,ex,ex)
DEFBINOP_POW(ex_scalar_pow,ex,scalar)
DEFBINOP_POW(scalar_ex_pow,scalar,ex)
DEFBINOP_POW(ex_vpa_pow,ex,vpa)
DEFBINOP_POW(ex_sym_pow,ex,sym)
 
void 
octave_ex::print(ostream& os,bool pr_as_read_syntax) const
{
  os << x;
}
 
octave_ex& octave_ex::operator=(const octave_ex& a)
{
  // GiNaC::ex *tmp;
  // tmp = (a.x.bp->duplicate());
  // return octave_ex(*tmp);
  return (*(new octave_ex(a.x)));
}

void 
install_ex_type()
{
  octave_ex::register_type();
  
  cerr << "installing ex type at type-id = " 
       << octave_ex::static_type_id() << "\n";
}

void 
install_ex_ops()
{
  INSTALL_UNOP(op_uminus, octave_ex, uminus);             // -x
  
  INSTALL_NCUNOP(op_incr, octave_ex, incr);               // x++
  INSTALL_NCUNOP(op_decr, octave_ex, decr);               // x--
  
  // Addition operations
  INSTALL_BINOP(op_add, octave_scalar, octave_ex, scalar_ex_add);
  INSTALL_BINOP(op_add, octave_ex, octave_scalar, ex_scalar_add);
  INSTALL_BINOP(op_add, octave_ex, octave_vpa, ex_vpa_add);
  INSTALL_BINOP(op_add, octave_ex, octave_ex, add);
  INSTALL_BINOP(op_add, octave_ex, octave_sym, ex_sym_add);
  
  // Subtraction operations
  INSTALL_BINOP(op_sub, octave_scalar, octave_ex, scalar_ex_sub);
  INSTALL_BINOP(op_sub, octave_ex, octave_scalar, ex_scalar_sub);
  INSTALL_BINOP(op_sub, octave_ex, octave_vpa, ex_vpa_sub);
  INSTALL_BINOP(op_sub, octave_ex, octave_ex, sub);
  INSTALL_BINOP(op_sub, octave_ex, octave_sym, ex_sym_sub);
  
  // Multiplication operations
  INSTALL_BINOP(op_mul, octave_scalar, octave_ex, scalar_ex_mul);
  INSTALL_BINOP(op_mul, octave_ex, octave_scalar, ex_scalar_mul);
  INSTALL_BINOP(op_mul, octave_ex, octave_vpa, ex_vpa_mul);
  INSTALL_BINOP(op_mul, octave_ex, octave_ex, mul);
  INSTALL_BINOP(op_mul, octave_ex, octave_sym, ex_sym_mul);
  
  // Division operations
  INSTALL_BINOP(op_div, octave_scalar, octave_ex, scalar_ex_div);
  INSTALL_BINOP(op_div, octave_ex, octave_scalar, ex_scalar_div);
  INSTALL_BINOP(op_div, octave_ex, octave_vpa, ex_vpa_div);
  INSTALL_BINOP(op_div, octave_ex, octave_ex, div);
  INSTALL_BINOP(op_div, octave_ex, octave_sym, ex_sym_div);
  
  // Power operations
  INSTALL_BINOP(op_pow, octave_scalar, octave_ex, scalar_ex_pow);
  INSTALL_BINOP(op_pow, octave_ex, octave_scalar, ex_scalar_pow);  
  INSTALL_BINOP(op_pow, octave_ex, octave_vpa, ex_vpa_pow);        
  INSTALL_BINOP(op_pow, octave_ex, octave_sym, ex_sym_pow);
  INSTALL_BINOP(op_pow, octave_ex, octave_ex, pow); 
}

DEFINE_OCTAVE_ALLOCATOR (octave_ex);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_ex, "ex");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
