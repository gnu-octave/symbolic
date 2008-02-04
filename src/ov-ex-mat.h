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
along with this program; If not, see <http://www.gnu.org/licenses/>.

*/

#if !defined (octave_ex_matrix_h)
#define octave_ex_matrix_h 1

#include <ginac/ginac.h>

class octave_matrix;
class octave_complex_matrix;

class 
octave_ex_matrix : public octave_base_value
{
public:
  octave_ex_matrix(void):octave_base_value() {}

  octave_ex_matrix(octave_ex_matrix &ox);
  octave_ex_matrix(octave_ex &ox);
  octave_ex_matrix(GiNaC::symbol sym);  
  octave_ex_matrix(GiNaC::matrix ex_mat);
  octave_ex_matrix(GiNaC::ex expression);
  octave_ex_matrix(int rows, int columns);
  octave_ex_matrix(octave_matrix ov);
  octave_ex_matrix(octave_complex_matrix ov);

  ~octave_ex_matrix() {}
  
  octave_ex_matrix& operator=(const octave_ex_matrix&);

  GiNaC::matrix ex_matrix_value(bool = false) const
    {
      return x;
    }
  
  GiNaC::ex ex_value(bool = false) const
    {
      return GiNaC::ex(x);
    }
  
  OV_REP_TYPE *clone (void) 
    { 
      return new octave_ex_matrix (*this); 
    }
  
  dim_vector dims (void) const {dim_vector dv (x.rows(), x.cols()); return dv; }
  int rows (void) const { return x.rows (); }
  int columns (void) const { return x.cols (); }
  
  bool is_constant (void) const { return true; }
  bool is_defined (void) const { return true; }

  bool valid_as_scalar_index(void) const {return false;}

  bool is_true(void) const { return true; }
   
  octave_value uminus (void) const { return new octave_ex_matrix(-x); } 

  void print(std::ostream& os,bool pr_as_read_syntax) const;
  
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
