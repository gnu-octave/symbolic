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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

*/

#include <octave/config.h>
#include <octave/ov-scalar.h>
#include <octave/ov-complex.h>
#include <octave/ov-re-mat.h>
#include <octave/ov-cx-mat.h>
#include <octave/oct-obj.h>
#include "sym-ops.h"
#include "ov-relational.h"
#include "ov-vpa.h"
#include "ov-ex.h"
#include "ov-ex-mat.h"

/* definitions for when vpa is first */
DEFINE_EX_MATRIX_OPS(vpa, ex_matrix)
DEFINE_EX_MATRIX_OPS(vpa, matrix)
DEFINE_EX_MATRIX_OPS(vpa, complex_matrix)
DEFINE_EX_EX_OPS(vpa, scalar)
DEFINE_EX_EX_OPS(vpa, complex)
DEFINE_EX_EX_OPS(vpa, vpa)
DEFINE_EX_EX_OPS(vpa, ex)

/* extra operators need for octave builtin types */ 
DEFINE_MATRIX_EX_OPS(complex_matrix, vpa)
DEFINE_MATRIX_EX_OPS(matrix, vpa)
DEFINE_EX_EX_OPS(scalar, vpa)
DEFINE_EX_EX_OPS(complex, vpa)

void install_vpa_ops()
{
  // INSTALL_UNOP (op_not, octave_vpa, not);
  /*
  INSTALL_UNOP (op_uminus, octave_vpa, uminus);
  INSTALL_UNOP (op_transpose, octave_vpa, transpose);
  INSTALL_UNOP (op_hermitian, octave_vpa, hermitian);
  
  INSTALL_NCUNOP (op_incr, octave_vpa, incr);
  INSTALL_NCUNOP (op_decr, octave_vpa, decr);
  */

  /* for when the vpa is first */
  INSTALL_EX_MATRIX_OPS(vpa, ex_matrix);
  INSTALL_EX_MATRIX_OPS(vpa, matrix);
  INSTALL_EX_MATRIX_OPS(vpa, complex_matrix);
  INSTALL_EX_EX_OPS(vpa, scalar);
  INSTALL_EX_EX_OPS(vpa, complex);
  INSTALL_EX_EX_OPS(vpa, vpa);
  INSTALL_EX_EX_OPS(vpa, ex);

  /* extra operators need for octave builtin types */ 
  INSTALL_MATRIX_EX_OPS(complex_matrix, vpa);
  INSTALL_MATRIX_EX_OPS(matrix, vpa);
  INSTALL_EX_EX_OPS(scalar, vpa);
  INSTALL_EX_EX_OPS(complex, vpa);


  /* 
  INSTALL_BINOP (op_lt, octave_vpa, octave_vpa, lt);
  INSTALL_BINOP (op_le, octave_vpa, octave_vpa, le);
  INSTALL_BINOP (op_eq, octave_vpa, octave_vpa, eq);
  INSTALL_BINOP (op_ge, octave_vpa, octave_vpa, ge);
  INSTALL_BINOP (op_gt, octave_vpa, octave_vpa, gt);
  INSTALL_BINOP (op_ne, octave_vpa, octave_vpa, ne);
  */
}
