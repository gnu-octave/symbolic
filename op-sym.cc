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
#include "sym-ops.h"
#include "ov-vpa.h"
#include "ov-sym.h"
#include "ov-ex.h"
#include "ov-ex-mat.h"

/* definitions for when the sym is first */
DEFINE_EX_MATRIX_OPS(sym, ex_matrix)
DEFINE_EX_MATRIX_OPS(sym, matrix)
DEFINE_EX_MATRIX_OPS(sym, complex_matrix)
DEFINE_EX_EX_OPS(sym, scalar)
DEFINE_EX_EX_OPS(sym, complex)
DEFINE_EX_EX_OPS(sym, vpa)
DEFINE_EX_EX_OPS(sym, sym)
DEFINE_EX_EX_OPS(sym, ex)

/* extra operators need for octave builtin types */ 
DEFINE_MATRIX_EX_OPS(complex_matrix, sym)
DEFINE_MATRIX_EX_OPS(matrix, sym)
DEFINE_EX_EX_OPS(scalar, sym)
DEFINE_EX_EX_OPS(complex, sym)

void
install_sym_ops()
{
#if 0
  INSTALL_UNOP(op_uminus, octave_sym, uminus);             // -x 
#endif

  /* for when the sym is first */
  INSTALL_EX_MATRIX_OPS(sym, ex_matrix);
  INSTALL_EX_MATRIX_OPS(sym, matrix);
  INSTALL_EX_MATRIX_OPS(sym, complex_matrix);
  INSTALL_EX_EX_OPS(sym, scalar);
  INSTALL_EX_EX_OPS(sym, complex);
  INSTALL_EX_EX_OPS(sym, vpa);
  INSTALL_EX_EX_OPS(sym, sym);
  INSTALL_EX_EX_OPS(sym, ex);
  
  /* extra operators need for octave builtin types */ 
  INSTALL_MATRIX_EX_OPS(complex_matrix, sym);
  INSTALL_MATRIX_EX_OPS(matrix, sym);
  INSTALL_EX_EX_OPS(scalar, sym);
  INSTALL_EX_EX_OPS(complex, sym);
}
