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
#include "ov-ex.h"
#include "ov-ex-mat.h"
#include "ov-vpa.h"

octave_ex_matrix::octave_ex_matrix(octave_ex_matrix &ox)
{
  x = ox.x;
}

octave_ex_matrix::octave_ex_matrix(octave_ex &ox)
{
  x = GiNaC::matrix(1,1);
  x(0,0) = ox.ex_value (); 
}

octave_ex_matrix::octave_ex_matrix(GiNaC::symbol sym)
{
  x = GiNaC::matrix(1,1);
  x(0,0) = GiNaC::ex(sym);
}
  
octave_ex_matrix::octave_ex_matrix(GiNaC::matrix ex_mat)
{
  x = ex_mat;
}

octave_ex_matrix::octave_ex_matrix(GiNaC::ex expression)
{
  x = GiNaC::matrix(1,1);
  x(0,0) = expression; 
}

octave_ex_matrix::octave_ex_matrix(int rows, int columns)
{
  x = GiNaC::matrix(rows,columns);
}

octave_ex_matrix::octave_ex_matrix(octave_matrix ov)
{
  Matrix mat = ov.matrix_value (); 
  
  int rows = mat.rows ();
  int cols = mat.cols (); 
  
  x = GiNaC::matrix(rows, cols);
  
  for (int i = 0; i < rows; i++)
    for (int j = 0; j < cols; j++)
      x(i,j) = GiNaC::ex(mat(i,j));
}

octave_ex_matrix::octave_ex_matrix(octave_complex_matrix ov)
{
    ComplexMatrix mat = ov.complex_matrix_value ();
    
    int rows = mat.rows ();
    int cols = mat.cols (); 
    
    x = GiNaC::matrix(rows, cols);
    
    for (int i = 0; i < rows; i++)
      for (int j = 0; j < cols; j++)
	x(i,j) = GiNaC::ex(mat(i,j).real ()) + GiNaC::I*GiNaC::ex(mat(i,j).imag ());
}


void 
octave_ex_matrix::print(std::ostream& os,bool pr_as_read_syntax) const
{
  os << x;
}
 
octave_ex_matrix& octave_ex_matrix::operator=(const octave_ex_matrix& a)
{
  return (*(new octave_ex_matrix(a.x)));
}

DEFINE_OCTAVE_ALLOCATOR (octave_ex_matrix);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_ex_matrix, "symbolic matrix");
