/*
Copyright (C) 2002 Benjamin Sapp

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
#include <octave/ov-re-mat.h>
#include <octave/ov-complex.h>
#include <octave/pager.h>
#include <octave/pr-output.h>
#include <octave/symtab.h>
#include <octave/variables.h>
#include <iostream>
#include <fstream>
#include "ov-ex.h"
#include "ov-ex-mat.h"
#include "ov-sym.h"
#include "ov-vpa.h"


#if 0
DEFUNOP_OP (uminus, ex, -)

DEFNCUNOP_METHOD (incr, ex, increment)
DEFNCUNOP_METHOD (decr, ex, decrement)

#endif 
 
// Addition operations
DEFBINOP_MATRIX_OP(ex_matrix_complex_matrix_add, ex_matrix, complex_matrix, add)
DEFBINOP_MATRIX_OP(complex_matrix_ex_matrix_add, complex_matrix, ex_matrix, add)
DEFBINOP_MATRIX_OP(ex_matrix_matrix_add, ex_matrix, matrix, add)
DEFBINOP_MATRIX_OP(matrix_ex_matrix_add, matrix, ex_matrix, add)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_complex_add, ex_matrix, complex, +)
DEFBINOP_SCALAR_EXMAT_OP(complex_ex_matrix_add, complex, ex_matrix, +)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_scalar_add,ex_matrix,scalar,+)
DEFBINOP_SCALAR_EXMAT_OP(scalar_ex_matrix_add,scalar,ex_matrix,+)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_vpa_add,ex_matrix,vpa,+)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_ex_add, ex_matrix, ex, +)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_sym_add,ex_matrix,sym,+)
DEFBINOP_MATRIX_OP(add,ex_matrix,ex_matrix,add)

// Subtraction operations
DEFBINOP_MATRIX_OP(ex_matrix_complex_matrix_sub, ex_matrix, complex_matrix, sub)
DEFBINOP_MATRIX_OP(complex_matrix_ex_matrix_sub, complex_matrix, ex_matrix, sub)
DEFBINOP_MATRIX_OP(ex_matrix_matrix_sub, ex_matrix, matrix, sub)
DEFBINOP_MATRIX_OP(matrix_ex_matrix_sub, matrix, ex_matrix, sub)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_complex_sub, ex_matrix, complex, -)
DEFBINOP_SCALAR_EXMAT_OP(complex_ex_matrix_sub, complex, ex_matrix, -)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_scalar_sub,ex_matrix,scalar, -)
DEFBINOP_SCALAR_EXMAT_OP(scalar_ex_matrix_sub,scalar,ex_matrix, -)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_vpa_sub,ex_matrix,vpa, -)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_ex_sub, ex_matrix, ex, -)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_sym_sub,ex_matrix,sym, -)
DEFBINOP_MATRIX_OP(sub,ex_matrix,ex_matrix,sub)

// multiplication operations
DEFBINOP_MATRIX_OP(ex_matrix_complex_matrix_mul, ex_matrix, complex_matrix, mul)
DEFBINOP_MATRIX_OP(complex_matrix_ex_matrix_mul, complex_matrix, ex_matrix, mul)
DEFBINOP_MATRIX_OP(ex_matrix_matrix_mul, ex_matrix, matrix, mul)
DEFBINOP_MATRIX_OP(matrix_ex_matrix_mul, matrix, ex_matrix, mul)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_complex_mul, ex_matrix, complex, *)
DEFBINOP_SCALAR_EXMAT_OP(complex_ex_matrix_mul, complex, ex_matrix, *)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_scalar_mul,ex_matrix,scalar, *)
DEFBINOP_SCALAR_EXMAT_OP(scalar_ex_matrix_mul,scalar,ex_matrix, *)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_vpa_mul,ex_matrix,vpa, *)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_ex_mul, ex_matrix, ex, *)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_sym_mul,ex_matrix,sym, *)
DEFBINOP_MATRIX_OP(mul,ex_matrix,ex_matrix,mul)

// "right division" operations
DEFBINOP_MATRIX_DIV(ex_matrix_complex_matrix_div, ex_matrix, complex_matrix)
DEFBINOP_MATRIX_DIV(complex_matrix_ex_matrix_div, complex_matrix, ex_matrix)
DEFBINOP_MATRIX_DIV(ex_matrix_matrix_div, ex_matrix, matrix)
DEFBINOP_MATRIX_DIV(matrix_ex_matrix_div, matrix, ex_matrix)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_complex_div, ex_matrix, complex, /)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_scalar_div,ex_matrix,scalar, /)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_vpa_div,ex_matrix,vpa, /)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_ex_div, ex_matrix, ex, /)
DEFBINOP_EXMAT_SCALAR_OP(ex_matrix_sym_div,ex_matrix,sym, /)
DEFBINOP_MATRIX_DIV(div,ex_matrix,ex_matrix)

// power operators
DEFBINOP_POW(ex_matrix_complex_pow, ex_matrix, complex)
DEFBINOP_POW(ex_matrix_scalar_pow,ex_matrix,scalar)
DEFBINOP_POW(ex_matrix_vpa_pow,ex_matrix,vpa)
DEFBINOP_POW(ex_matrix_ex_pow, ex_matrix, ex)
DEFBINOP_POW(ex_matrix_sym_pow,ex_matrix,sym)

void 
octave_ex_matrix::print(ostream& os,bool pr_as_read_syntax) const
{
  os << x;
}
 
octave_ex_matrix& octave_ex_matrix::operator=(const octave_ex_matrix& a)
{
  // GiNaC::ex *tmp;
  // tmp = (a.x.bp->duplicate());
  // return octave_ex(*tmp);
  return (*(new octave_ex_matrix(a.x)));
}

void 
install_ex_matrix_type()
{
  octave_ex_matrix::register_type();
  
  cerr << "installing ex matrix type at type-id = " 
       << octave_ex_matrix::static_type_id() << "\n";
}


void 
install_ex_matrix_ops()
{
  // Install addition operators
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_complex_matrix, ex_matrix_complex_matrix_add);
  INSTALL_BINOP(op_add, octave_complex_matrix, octave_ex_matrix, complex_matrix_ex_matrix_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_matrix, ex_matrix_matrix_add);
  INSTALL_BINOP(op_add, octave_matrix, octave_ex_matrix, matrix_ex_matrix_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_complex, ex_matrix_complex_add);
  INSTALL_BINOP(op_add, octave_complex, octave_ex_matrix, complex_ex_matrix_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_scalar, ex_matrix_scalar_add);
  INSTALL_BINOP(op_add, octave_scalar, octave_ex_matrix, scalar_ex_matrix_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_vpa, ex_matrix_vpa_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_ex, ex_matrix_ex_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_sym, ex_matrix_sym_add);
  INSTALL_BINOP(op_add, octave_ex_matrix, octave_ex_matrix, add);

  // Install subtraction operators
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_complex_matrix, ex_matrix_complex_matrix_sub);
  INSTALL_BINOP(op_sub, octave_complex_matrix, octave_ex_matrix, complex_matrix_ex_matrix_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_matrix, ex_matrix_matrix_sub);
  INSTALL_BINOP(op_sub, octave_matrix, octave_ex_matrix, matrix_ex_matrix_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_complex, ex_matrix_complex_sub);
  INSTALL_BINOP(op_sub, octave_complex, octave_ex_matrix, complex_ex_matrix_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_scalar, ex_matrix_scalar_sub);
  INSTALL_BINOP(op_sub, octave_scalar, octave_ex_matrix, scalar_ex_matrix_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_vpa, ex_matrix_vpa_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_ex, ex_matrix_ex_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_sym, ex_matrix_sym_sub);
  INSTALL_BINOP(op_sub, octave_ex_matrix, octave_ex_matrix, sub);

  // Install multiplication operators
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_complex_matrix, ex_matrix_complex_matrix_mul);
  INSTALL_BINOP(op_mul, octave_complex_matrix, octave_ex_matrix, complex_matrix_ex_matrix_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_matrix, ex_matrix_matrix_mul);
  INSTALL_BINOP(op_mul, octave_matrix, octave_ex_matrix, matrix_ex_matrix_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_complex, ex_matrix_complex_mul);
  INSTALL_BINOP(op_mul, octave_complex, octave_ex_matrix, complex_ex_matrix_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_scalar, ex_matrix_scalar_mul);
  INSTALL_BINOP(op_mul, octave_scalar, octave_ex_matrix, scalar_ex_matrix_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_vpa, ex_matrix_vpa_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_ex, ex_matrix_ex_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_sym, ex_matrix_sym_mul);
  INSTALL_BINOP(op_mul, octave_ex_matrix, octave_ex_matrix, mul);

  // Install "right division" operators
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_complex_matrix, ex_matrix_complex_matrix_div);
  INSTALL_BINOP(op_div, octave_complex_matrix, octave_ex_matrix, complex_matrix_ex_matrix_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_matrix, ex_matrix_matrix_div);
  INSTALL_BINOP(op_div, octave_matrix, octave_ex_matrix, matrix_ex_matrix_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_complex, ex_matrix_complex_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_scalar, ex_matrix_scalar_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_vpa, ex_matrix_vpa_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_ex, ex_matrix_ex_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_sym, ex_matrix_sym_div);
  INSTALL_BINOP(op_div, octave_ex_matrix, octave_ex_matrix, div);

  // Install power operators
  INSTALL_BINOP(op_pow, octave_ex_matrix, octave_complex, ex_matrix_complex_pow);
  INSTALL_BINOP(op_pow, octave_ex_matrix, octave_scalar, ex_matrix_scalar_pow);
  INSTALL_BINOP(op_pow, octave_ex_matrix, octave_vpa, ex_matrix_vpa_pow);
  INSTALL_BINOP(op_pow, octave_ex_matrix, octave_ex, ex_matrix_ex_pow);
  INSTALL_BINOP(op_pow, octave_ex_matrix, octave_sym, ex_matrix_sym_pow);

#if 0

  INSTALL_UNOP(op_uminus, octave_ex, uminus);             // -x
  
  INSTALL_NCUNOP(op_incr, octave_ex, incr);               // x++
  INSTALL_NCUNOP(op_decr, octave_ex, decr);               // x--

#endif
}

DEFINE_OCTAVE_ALLOCATOR (octave_ex_matrix);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_ex_matrix, "symbolic matrix");
