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

#if !defined (octave_ex_matrix_h)
#define octave_ex_matrix_h 1

#include <ginac/ginac.h>
#include <octave/ov-re-mat.h>
#include <octave/ov-cx-mat.h>

void install_ex_matrix_type();
void install_ex_matrix_ops();

#define DEFBINOP_MATRIX_OP(name, t1, t2, op) \
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
    catch (exception &e) \
      { \
        error(e.what()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_MATRIX_DIV(name, t1, t2) \
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
    catch (exception &e) \
      { \
        error(e.what()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_SCALAR_EXMAT_OP(name, t1, t2, op) \
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
    catch (exception &e) \
      { \
        error(e.what()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_EXMAT_SCALAR_OP(name, t1, t2, op) \
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
    catch (exception &e) \
      { \
        error(e.what()); \
        return octave_value (); \
      } \
  }

#define DEFBINOP_POW(name, t1, t2) \
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
    catch (exception &e) \
      { \
        error(e.what()); \
        return octave_value (); \
      } \
  }

class 
octave_ex_matrix : public octave_base_value
{
public:
  octave_ex_matrix(void):octave_base_value() {}

  octave_ex_matrix(octave_ex_matrix &ox)
    {
      x = ox.x;
    }

  octave_ex_matrix(octave_ex &ox)
    {
      x = GiNaC::matrix(1,1);
      x(0,0) = ox.ex_value (); 
    }

  octave_ex_matrix(GiNaC::symbol sym)
    {
      x = GiNaC::matrix(1,1);
      x(0,0) = GiNaC::ex(sym);
    }
  
  octave_ex_matrix(GiNaC::matrix ex_mat)
    {
      x = ex_mat;
    }

  octave_ex_matrix(GiNaC::ex expression)
    {
      x = GiNaC::matrix(1,1);
      x(0,0) = expression; 
    }

  octave_ex_matrix(int rows, int columns)
    {
      x = GiNaC::matrix(rows,columns);
    }

  octave_ex_matrix(octave_matrix ov)
    {
      Matrix mat = ov.matrix_value (); 

      int rows = mat.rows ();
      int cols = mat.cols (); 

      x = GiNaC::matrix(rows, cols);

      for (int i = 0; i < rows; i++)
	for (int j = 0; j < cols; j++)
	  x(i,j) = GiNaC::ex(mat(i,j));
    }

  octave_ex_matrix(octave_complex_matrix ov)
  {
    ComplexMatrix mat = ov.complex_matrix_value ();

    int rows = mat.rows ();
    int cols = mat.cols (); 
    
    x = GiNaC::matrix(rows, cols);
    
    for (int i = 0; i < rows; i++)
      for (int j = 0; j < cols; j++)
	x(i,j) = GiNaC::ex(mat(i,j).real ()) + GiNaC::I*GiNaC::ex(mat(i,j).imag ());
  }

  ~octave_ex_matrix() {}
  
  octave_ex_matrix& operator=(const octave_ex_matrix&);

  GiNaC::matrix ex_matrix_value(bool = false) const
    {
      // GiNaC::ex tmp = *(x.bp->duplicate());
      // return tmp;
      return x;
    }
  
  GiNaC::ex ex_value(bool = false) const
    {
      // GiNaC::ex tmp = *(x.bp->duplicate());
      // return tmp;
      return GiNaC::ex(x);
    }
  
  octave_value *clone (void) 
    { 
      return new octave_ex_matrix (*this); 
    }
  
  int rows (void) const { return x.rows (); }
  int columns (void) const { return x.cols (); }
  
  bool is_constant (void) const { return true; }
  bool is_defined (void) const { return true; }

  bool valid_as_scalar_index(void) const {return false;}

  bool is_true(void) const { return true; }
   
  octave_value uminus (void) const { return new octave_ex_matrix(-x); } 
  /*
  void increment (void) { x = x+1;}

  void decrement (void) { x = x-1;}
  */ 
  void print(ostream& os,bool pr_as_read_syntax) const;
  
private:
  GiNaC::matrix x;

  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA  

};


#endif 

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
