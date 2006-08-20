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

#if !defined (sym_ops_h)
#define sym_ops_h 1

#include <octave/ops.h>
#include <octave/ov-bool.h>

/* This file defines macros used in the op-X.cc files to define functions
 */

void install_ex_ops(void); 
void install_vpa_ops(void);
void install_ex_matrix_ops(void);

#define DEFBINOP_MATRIX_MATRIX_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
        GiNaC::matrix r1 = octave_ex_matrix(v1.t1 ## _value ()).ex_matrix_value (); \
	GiNaC::matrix r2 = octave_ex_matrix(v2.t2 ## _value ()).ex_matrix_value (); \
        if ( (r1.rows () != r2.rows ()) || (r1.cols () != r2.cols ()) ) \
          { \
	    error("nonconformant arguments\n"); \
	    return octave_value (); \
	  } \
        return octave_value \
          (new octave_ex_matrix (r1.op (r2))); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_MATRIX_MATRIX_DIV(name, t1, t2) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
        GiNaC::matrix r1 = octave_ex_matrix(v1.t1 ## _value ()).ex_matrix_value (); \
	GiNaC::matrix r2 = octave_ex_matrix(v2.t2 ## _value ()).ex_matrix_value (); \
        if ( (r1.rows () != r2.rows ()) || (r1.cols () != r2.cols ()) ) \
          { \
	    error("nonconformant arguments\n"); \
	    return octave_value (); \
	  } \
        return octave_value \
          (new octave_ex_matrix (r2.transpose ().inverse ().mul (r1).transpose ())); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_EX_MATRIX_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
	GiNaC::matrix r1 = octave_ex_matrix(v2.t2 ## _value ()).ex_matrix_value (); \
	GiNaC::ex r2 = octave_ex(v1.t1 ## _value ()).ex_value (); \
        int rows = int(r1.rows ()); \
        int cols = int(r1.cols ()); \
	GiNaC::matrix result(rows, cols); \
        for (int i = 0; i < rows; i++) \
	  for (int j = 0; j < cols; j++) \
	    result(i,j) = r1(i,j) op r2; \
      return octave_value \
          (new octave_ex_matrix (result)); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_MATRIX_EX_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
	GiNaC::matrix r1 = octave_ex_matrix(v1.t1 ## _value ()).ex_matrix_value (); \
	GiNaC::ex r2 = octave_ex(v2.t2 ## _value ()).ex_value (); \
        int rows = int(r1.rows ()); \
        int cols = int(r1.cols ()); \
	GiNaC::matrix result(rows, cols); \
        for (int i = 0; i < rows; i++) \
	  for (int j = 0; j < cols; j++) \
	    result(i,j) = r1(i,j) op r2; \
        return octave_value \
          (new octave_ex_matrix (result)); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_MATRIX_EX_POW(name, t1, t2) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
	GiNaC::matrix r1 = octave_ex_matrix(v1.t1 ## _value ()).ex_matrix_value (); \
	GiNaC::ex r2 = octave_ex(v2.t2 ## _value ()).ex_value (); \
        int rows = int(r1.rows ()); \
        int cols = int(r1.cols ()); \
	GiNaC::matrix result(rows, cols); \
        for (int i = 0; i < rows; i++) \
	  for (int j = 0; j < cols; j++) \
	    result(i,j) = GiNaC::pow(r1(i,j), r2); \
      return octave_value \
          (new octave_ex_matrix (result)); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_EX_EX_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
	GiNaC::ex r1 = octave_ex(v1.t1 ## _value ()).ex_value (); \
	GiNaC::ex r2 = octave_ex(v2.t2 ## _value ()).ex_value (); \
	GiNaC::ex result = r1 op r2; \
        return octave_value \
          (new octave_ex (result)); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_EX_EX_POW(name, t1, t2) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
	GiNaC::ex r1 = octave_ex(v1.t1 ## _value ()).ex_value (); \
	GiNaC::ex r2 = octave_ex(v2.t2 ## _value ()).ex_value (); \
	GiNaC::ex result = pow(r1,r2); \
        return octave_value \
          (new octave_ex (result)); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_EX_EX_BOOL_OP(name, t1, t2, op) \
  BINOPDECL (name, a1, a2) \
  { \
    try \
      { \
        CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
	GiNaC::ex r1 = octave_ex(v1.t1 ## _value ()).ex_value (); \
	GiNaC::ex r2 = octave_ex(v2.t2 ## _value ()).ex_value (); \
        if (GiNaC::is_exactly_a<GiNaC::numeric>(r1) && \
	    GiNaC::is_exactly_a<GiNaC::numeric>(r2)) \
          { \
            bool tmp_bool = GiNaC::relational(r1, r2, op); \
            return octave_value(tmp_bool); \
	  } \
        return octave_value \
          (new octave_relational (r1, r2, op)); \
      } \
    catch (std::exception &e) \
      { \
        error (e.what ()); \
        return octave_value (); \
      } \
  }


#define DEFINE_MATRIX_EX_OPS(TYPE1, TYPE2) \
DEFBINOP_MATRIX_EX_OP  (TYPE1 ## _ ## TYPE2 ## _add, TYPE1, TYPE2, +) \
DEFBINOP_MATRIX_EX_OP  (TYPE1 ## _ ## TYPE2 ## _sub, TYPE1, TYPE2, -) \
DEFBINOP_MATRIX_EX_OP  (TYPE1 ## _ ## TYPE2 ## _mul, TYPE1, TYPE2, *) \
DEFBINOP_MATRIX_EX_OP  (TYPE1 ## _ ## TYPE2 ## _div, TYPE1, TYPE2, /) \
DEFBINOP_MATRIX_EX_POW (TYPE1 ## _ ## TYPE2 ## _pow, TYPE1, TYPE2) 

#define INSTALL_MATRIX_EX_OPS(TYPE1, TYPE2) \
INSTALL_BINOP(op_add, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _add) \
INSTALL_BINOP(op_sub, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _sub) \
INSTALL_BINOP(op_mul, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _mul) \
INSTALL_BINOP(op_div, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _div) \
INSTALL_BINOP(op_pow, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _pow) 

#define DEFINE_EX_MATRIX_OPS(TYPE1, TYPE2) \
DEFBINOP_EX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _add, TYPE1, TYPE2, +) \
DEFBINOP_EX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _sub, TYPE1, TYPE2, -) \
DEFBINOP_EX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _mul, TYPE1, TYPE2, *) \
DEFBINOP_EX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _div, TYPE1, TYPE2, /) 
// DEFBINOP_EX_MATRIX_POW (TYPE1 ## _ ## TYPE2 ## _pow, TYPE1, TYPE2)

#define INSTALL_EX_MATRIX_OPS(TYPE1, TYPE2) \
INSTALL_BINOP(op_add, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _add) \
INSTALL_BINOP(op_sub, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _sub) \
INSTALL_BINOP(op_mul, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _mul) \
INSTALL_BINOP(op_div, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _div)
// INSTALL_BINOP(op_pow, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _pow)

#define DEFINE_EX_EX_OPS(TYPE1, TYPE2) \
DEFBINOP_EX_EX_OP     (TYPE1 ## _ ## TYPE2 ## _add,              TYPE1, TYPE2, +) \
DEFBINOP_EX_EX_OP     (TYPE1 ## _ ## TYPE2 ## _sub,              TYPE1, TYPE2, -) \
DEFBINOP_EX_EX_OP     (TYPE1 ## _ ## TYPE2 ## _mul,              TYPE1, TYPE2, *) \
DEFBINOP_EX_EX_OP     (TYPE1 ## _ ## TYPE2 ## _div,              TYPE1, TYPE2, /) \
DEFBINOP_EX_EX_POW    (TYPE1 ## _ ## TYPE2 ## _pow,              TYPE1, TYPE2) \
DEFBINOP_EX_EX_BOOL_OP(TYPE1 ## _ ## TYPE2 ## _equal,            TYPE1, TYPE2, GiNaC::relational::equal) \
DEFBINOP_EX_EX_BOOL_OP(TYPE1 ## _ ## TYPE2 ## _not_equal,        TYPE1, TYPE2, GiNaC::relational::not_equal) \
DEFBINOP_EX_EX_BOOL_OP(TYPE1 ## _ ## TYPE2 ## _less,             TYPE1, TYPE2, GiNaC::relational::less) \
DEFBINOP_EX_EX_BOOL_OP(TYPE1 ## _ ## TYPE2 ## _less_or_equal,    TYPE1, TYPE2, GiNaC::relational::less_or_equal) \
DEFBINOP_EX_EX_BOOL_OP(TYPE1 ## _ ## TYPE2 ## _greater,          TYPE1, TYPE2, GiNaC::relational::greater) \
DEFBINOP_EX_EX_BOOL_OP(TYPE1 ## _ ## TYPE2 ## _greater_or_equal, TYPE1, TYPE2, GiNaC::relational::greater_or_equal)

#define INSTALL_EX_EX_OPS(TYPE1, TYPE2) \
INSTALL_BINOP(op_add, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _add) \
INSTALL_BINOP(op_sub, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _sub) \
INSTALL_BINOP(op_mul, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _mul) \
INSTALL_BINOP(op_div, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _div) \
INSTALL_BINOP(op_pow, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _pow) \
INSTALL_BINOP(op_eq,  octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _equal) \
INSTALL_BINOP(op_ne,  octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _not_equal) \
INSTALL_BINOP(op_lt,  octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _less) \
INSTALL_BINOP(op_le,  octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _less_or_equal) \
INSTALL_BINOP(op_gt,  octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _greater) \
INSTALL_BINOP(op_ge,  octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _greater_or_equal);

#define DEFINE_MATRIX_MATRIX_OPS(TYPE1, TYPE2) \
DEFBINOP_MATRIX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _add, TYPE1, TYPE2, add) \
DEFBINOP_MATRIX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _sub, TYPE1, TYPE2, sub) \
DEFBINOP_MATRIX_MATRIX_OP  (TYPE1 ## _ ## TYPE2 ## _mul, TYPE1, TYPE2, mul) \
DEFBINOP_MATRIX_MATRIX_DIV (TYPE1 ## _ ## TYPE2 ## _div, TYPE1, TYPE2)

#define INSTALL_MATRIX_MATRIX_OPS(TYPE1, TYPE2) \
INSTALL_BINOP(op_add, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _add) \
INSTALL_BINOP(op_sub, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _sub) \
INSTALL_BINOP(op_mul, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _mul) \
INSTALL_BINOP(op_div, octave_ ## TYPE1, octave_ ## TYPE2, TYPE1 ## _ ## TYPE2 ## _div) 

#endif 

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
