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
#include "ov-vpa.h"
#include "ov-ex.h"
#include "ov-sym.h"

void
octave_vpa::print (ostream& os, bool pr_as_read_syntax) const
{
  os << scalar;
}


#ifdef DEFUNOP_OP
#undef DEFUNOP_OP
#endif

#define DEFUNOP_OP(name, t, op) \
  UNOPDECL (name, a) \
  { \
    CAST_UNOP_ARG (const octave_ ## t&); \
    return octave_value (new octave_vpa (op v.t ## _value ())); \
  }

// DEFUNOP_OP (not, vpa, !)
DEFUNOP_OP (uminus, vpa, -)
DEFUNOP_OP (transpose, vpa, /* no-op */)
DEFUNOP_OP (hermitian, vpa, /* no-op */)

DEFNCUNOP_METHOD (incr, vpa, increment)
DEFNCUNOP_METHOD (decr, vpa, decrement)

#ifdef DEFBINOP_OP
#undef DEFBINOP_OP
#endif

#define DEFBINOP_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    return octave_value \
      (new octave_vpa (v1.t1 ## _value () op v2.t2 ## _value ())); \
  }

#define DEFBINOP_OP_NUM(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    return octave_value \
      (new octave_vpa (v1.t1 ## _value () op v2.t2 ## _value ())); \
  }

#define DEFBINOP_OP_EX(name, t1, t2, op) \
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

// relational ops.
DEFBINOP_OP (lt, vpa, vpa, <)
DEFBINOP_OP (le, vpa, vpa, <=)
DEFBINOP_OP (eq, vpa, vpa, ==)
DEFBINOP_OP (ge, vpa, vpa, >=)
DEFBINOP_OP (gt, vpa, vpa, >)
DEFBINOP_OP (ne, vpa, vpa, !=)
  //DEFBINOP_OP (el_mul, vpa, vpa, !=)

  //#error The type of return arguements in sym_vpa class are not always correct

// Addition operations
DEFBINOP_OP_NUM(vpa_scalar_add,vpa,scalar,+)
DEFBINOP_OP_NUM(scalar_vpa_add,scalar,vpa,+)
DEFBINOP_OP_NUM (add, vpa, vpa, +)
DEFBINOP_OP_EX(vpa_sym_add,vpa,sym,+)
DEFBINOP_OP_EX(vpa_ex_add,vpa,ex,+)

// Subtraction operations
DEFBINOP_OP_NUM(vpa_scalar_sub,vpa,scalar,-)
DEFBINOP_OP_NUM(scalar_vpa_sub,scalar,vpa,-)
DEFBINOP_OP_NUM(sub, vpa, vpa, -)
DEFBINOP_OP_EX(vpa_sym_sub,vpa,sym,-)
DEFBINOP_OP_EX(vpa_ex_sub,vpa,ex,-)

// Multiplication operations
DEFBINOP_OP_NUM(vpa_scalar_mul,vpa,scalar,*)
DEFBINOP_OP_NUM(scalar_vpa_mul,scalar,vpa,*)
DEFBINOP_OP_NUM(mul, vpa, vpa, *)
DEFBINOP_OP_EX(vpa_sym_mul,vpa,sym,*)
DEFBINOP_OP_EX(vpa_ex_mul,vpa,ex,*)

// Division operations
DEFBINOP_OP_NUM(vpa_scalar_div,vpa,scalar,/)
DEFBINOP_OP_NUM(scalar_vpa_div,scalar,vpa,/)
DEFBINOP_OP_NUM(div, vpa, vpa, /)
DEFBINOP_OP_EX(vpa_sym_div,vpa,sym,/)
DEFBINOP_OP_EX(vpa_ex_div,vpa,ex,/)

// Power operations 
DEFBINOP_POW(pow,vpa,vpa)
DEFBINOP_POW(vpa_scalar_pow,vpa,scalar)
DEFBINOP_POW(scalar_vpa_pow,scalar,vpa)
DEFBINOP_POW(vpa_sym_pow,vpa,sym) 
DEFBINOP_POW(vpa_ex_pow,vpa,ex)

void 
install_vpa_type()
{
  octave_vpa::register_type ();
  
  cerr << "installing vpa type at type-id = "
       << octave_vpa::static_type_id () << "\n";
}

void install_vpa_ops()
{
  // INSTALL_UNOP (op_not, octave_vpa, not);
  INSTALL_UNOP (op_uminus, octave_vpa, uminus);
  INSTALL_UNOP (op_transpose, octave_vpa, transpose);
  INSTALL_UNOP (op_hermitian, octave_vpa, hermitian);
  
  INSTALL_NCUNOP (op_incr, octave_vpa, incr);
  INSTALL_NCUNOP (op_decr, octave_vpa, decr);
  
  // Addition operations
  INSTALL_BINOP(op_add, octave_scalar, octave_vpa, scalar_vpa_add);
  INSTALL_BINOP(op_add, octave_vpa, octave_scalar, vpa_scalar_add);
  INSTALL_BINOP(op_add, octave_vpa, octave_vpa, add);
  INSTALL_BINOP(op_add, octave_vpa, octave_sym, vpa_sym_add);
  INSTALL_BINOP(op_add, octave_vpa, octave_ex, vpa_ex_add);
  
  // Subtraction operations
  INSTALL_BINOP(op_sub, octave_scalar, octave_vpa, scalar_vpa_sub);
  INSTALL_BINOP(op_sub, octave_vpa, octave_scalar, vpa_scalar_sub);
  INSTALL_BINOP(op_sub, octave_vpa, octave_vpa, sub);
  INSTALL_BINOP(op_sub, octave_vpa, octave_sym, vpa_sym_sub);
  INSTALL_BINOP(op_sub, octave_vpa, octave_ex, vpa_ex_sub);
  
  // Multiplication operations
  INSTALL_BINOP(op_mul, octave_scalar, octave_vpa, scalar_vpa_mul);
  INSTALL_BINOP(op_mul, octave_vpa, octave_scalar, vpa_scalar_mul);
  INSTALL_BINOP(op_mul, octave_vpa, octave_vpa, mul);
  INSTALL_BINOP(op_mul, octave_vpa, octave_sym, vpa_sym_mul);
  INSTALL_BINOP(op_mul, octave_vpa, octave_ex, vpa_ex_mul);
  
  // Division operations
  INSTALL_BINOP(op_div, octave_scalar, octave_vpa, scalar_vpa_div);
  INSTALL_BINOP(op_div, octave_vpa, octave_scalar, vpa_scalar_div);
  INSTALL_BINOP(op_div, octave_vpa, octave_vpa, div);
  INSTALL_BINOP(op_div, octave_vpa, octave_sym, vpa_sym_div);
  INSTALL_BINOP(op_div, octave_vpa, octave_ex, vpa_ex_div);
  
  // Power operations
  INSTALL_BINOP(op_pow, octave_scalar, octave_vpa, scalar_vpa_pow);
  INSTALL_BINOP(op_pow, octave_vpa, octave_scalar, vpa_scalar_pow);  
  INSTALL_BINOP(op_pow, octave_vpa, octave_vpa, pow);        
  INSTALL_BINOP(op_pow, octave_vpa, octave_sym, vpa_sym_pow);
  INSTALL_BINOP(op_pow, octave_vpa, octave_ex, vpa_ex_pow);
  
  INSTALL_BINOP (op_lt, octave_vpa, octave_vpa, lt);
  INSTALL_BINOP (op_le, octave_vpa, octave_vpa, le);
  INSTALL_BINOP (op_eq, octave_vpa, octave_vpa, eq);
  INSTALL_BINOP (op_ge, octave_vpa, octave_vpa, ge);
  INSTALL_BINOP (op_gt, octave_vpa, octave_vpa, gt);
  INSTALL_BINOP (op_ne, octave_vpa, octave_vpa, ne);
  
}

DEFINE_OCTAVE_ALLOCATOR (octave_vpa);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_vpa, "vpa");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
