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

#include <octave/lo-mappers.h>
#include <octave/lo-utils.h>
#include <octave/mx-base.h>
#include <octave/str-vec.h>

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

DEFUNOP_OP (uminus, sym, -)

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
DEFBINOP_OP(sym_scalar_add,sym,scalar,+)
DEFBINOP_OP(scalar_sym_add,scalar,sym,+)
DEFBINOP_OP(sym_vpa_add,sym,vpa,+)
DEFBINOP_OP (sym_sym_add, sym, sym, +)
DEFBINOP_OP(sym_ex_add,sym,ex,+)

// Subtraction operations
DEFBINOP_OP(sym_scalar_sub,sym,scalar,-)
DEFBINOP_OP(scalar_sym_sub,scalar,sym,-)
DEFBINOP_OP(sym_vpa_sub,sym,vpa,-)
DEFBINOP_OP (sym_sym_sub, sym, sym, -)
DEFBINOP_OP(sym_ex_sub,sym,ex,-)

// Multiplication operations
DEFBINOP_OP(sym_scalar_mul,sym,scalar,*)
DEFBINOP_OP(scalar_sym_mul,scalar,sym,*)
DEFBINOP_OP(sym_vpa_mul,sym,vpa,*)
DEFBINOP_OP (sym_sym_mul, sym, sym, *)
DEFBINOP_OP(sym_ex_mul,sym,ex,*)

// Division operations
DEFBINOP_OP(sym_scalar_div,sym,scalar,/)
DEFBINOP_OP(scalar_sym_div,scalar,sym,/)
DEFBINOP_OP(sym_vpa_div,sym,vpa,/)
DEFBINOP_OP (sym_sym_div, sym, sym, /)
DEFBINOP_OP(sym_ex_div,sym,ex,/)

// Power operations 
DEFBINOP_POW(sym_sym_pow,sym,sym)
DEFBINOP_POW(sym_scalar_pow,sym,scalar)
DEFBINOP_POW(scalar_sym_pow,scalar,sym)
DEFBINOP_POW(sym_vpa_pow,sym,vpa)
DEFBINOP_POW(sym_ex_pow,sym,ex)

GiNaC::symbol octave_sym::sym_value() const 
{
  // This is ugly
  return ex_to_symbol(GiNaC::ex(*(x.duplicate ())));
}

void 
install_sym_type()
{ 
  octave_sym::register_type();
  
  cerr << "installing sym type at type-id = " 
       << octave_sym::static_type_id() << "\n";
}

void
install_sym_ops()
{
  INSTALL_UNOP(op_uminus, octave_sym, uminus);             // -x 
  
  // Addition operations
  INSTALL_BINOP(op_add, octave_scalar, octave_sym, scalar_sym_add);
  INSTALL_BINOP(op_add, octave_sym, octave_scalar, sym_scalar_add);
  INSTALL_BINOP(op_add, octave_sym, octave_vpa, sym_vpa_add);
  INSTALL_BINOP(op_add, octave_sym, octave_sym, sym_sym_add);
  INSTALL_BINOP(op_add, octave_sym, octave_ex, sym_ex_add);
  
  // Subtraction operations
  INSTALL_BINOP(op_sub, octave_scalar, octave_sym, scalar_sym_sub);
  INSTALL_BINOP(op_sub, octave_sym, octave_scalar, sym_scalar_sub);
  INSTALL_BINOP(op_sub, octave_sym, octave_vpa, sym_vpa_sub);
  INSTALL_BINOP(op_sub, octave_sym, octave_sym, sym_sym_sub);
  INSTALL_BINOP(op_sub, octave_sym, octave_ex, sym_ex_sub);
  
  // Multiplication operations
  INSTALL_BINOP(op_mul, octave_scalar, octave_sym, scalar_sym_mul);
  INSTALL_BINOP(op_mul, octave_sym, octave_scalar, sym_scalar_mul);
  INSTALL_BINOP(op_mul, octave_sym, octave_vpa, sym_vpa_mul);
  INSTALL_BINOP(op_mul, octave_sym, octave_sym, sym_sym_mul);
  INSTALL_BINOP(op_mul, octave_sym, octave_ex, sym_ex_mul);
  
  // Division operations
  INSTALL_BINOP(op_div, octave_scalar, octave_sym, scalar_sym_div);
  INSTALL_BINOP(op_div, octave_sym, octave_scalar, sym_scalar_div);
  INSTALL_BINOP(op_div, octave_sym, octave_vpa, sym_vpa_div);
  INSTALL_BINOP(op_div, octave_sym, octave_sym, sym_sym_div);
  INSTALL_BINOP(op_div, octave_sym, octave_ex, sym_ex_div);
  
  // Power operations
  INSTALL_BINOP(op_pow, octave_scalar, octave_sym, scalar_sym_pow);
  INSTALL_BINOP(op_pow, octave_sym, octave_scalar, sym_scalar_pow);  
  INSTALL_BINOP(op_pow, octave_sym, octave_vpa, sym_vpa_pow);        
  INSTALL_BINOP(op_pow, octave_sym, octave_sym, sym_sym_pow);
  INSTALL_BINOP(op_pow, octave_sym, octave_ex, sym_ex_pow);
}  

DEFINE_OCTAVE_ALLOCATOR (octave_sym);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_sym, "sym");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
