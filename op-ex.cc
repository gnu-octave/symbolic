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

/* definitions for when ex is first */
DEFINE_EX_MATRIX_OPS(ex, ex_matrix)
DEFINE_EX_MATRIX_OPS(ex, matrix)
DEFINE_EX_MATRIX_OPS(ex, complex_matrix)
DEFINE_EX_EX_OPS(ex, scalar)
DEFINE_EX_EX_OPS(ex, complex)
DEFINE_EX_EX_OPS(ex, vpa)
DEFINE_EX_EX_OPS(ex, ex)

/* extra operators need for octave builtin types */ 
DEFINE_MATRIX_EX_OPS(complex_matrix, ex)
DEFINE_MATRIX_EX_OPS(matrix, ex)
DEFINE_EX_EX_OPS(scalar, ex)
DEFINE_EX_EX_OPS(complex, ex)

void 
install_ex_ops()
{
  INSTALL_EX_MATRIX_OPS(ex, ex_matrix);
  INSTALL_EX_MATRIX_OPS(ex, matrix);
  INSTALL_EX_MATRIX_OPS(ex, complex_matrix);
  INSTALL_EX_EX_OPS(ex, scalar);
  INSTALL_EX_EX_OPS(ex, complex);
  INSTALL_EX_EX_OPS(ex, vpa);
  INSTALL_EX_EX_OPS(ex, ex);

  /* extra operators need for octave builtin types */ 
  INSTALL_MATRIX_EX_OPS(complex_matrix, ex);
  INSTALL_MATRIX_EX_OPS(matrix, ex);
  INSTALL_EX_EX_OPS(scalar, ex);
  INSTALL_EX_EX_OPS(complex, ex);
 
#if 0
  INSTALL_UNOP(op_uminus, octave_ex, uminus);             // -x
  
  INSTALL_NCUNOP(op_incr, octave_ex, incr);               // x++
  INSTALL_NCUNOP(op_decr, octave_ex, decr);               // x--
#endif
}
