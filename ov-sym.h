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

#if !defined (octave_sym_h)
#define octave_sym_h 1

#include <ginac/ginac.h>
#include "ov-base.h"

class octave_ex;

class 
octave_sym : public octave_base_value
{
public:
  octave_sym(void){}
  octave_sym(char *str);
  octave_sym(const octave_sym &xtmp):x(xtmp.x){}
  octave_sym(GiNaC::symbol xtmp):x(xtmp){}

  ~octave_sym (void) {}

  octave_value *clone (void) {return new octave_sym(*this);}

  GiNaC::symbol sym_value(void) const;

  octave_value uminus (void); 

  void print(std::ostream& os,bool pr_as_read_syntax) const;

  int rows (void) const { return 1; }
  int columns (void) const { return 1; }

  bool is_constant (void) const { return true; }
  bool is_defined (void) const { return true; }
  bool is_real_scalar (void) const { return false; }
  
  bool is_real_type(void) const {return false;}
  bool is_scalar_type(void) const {return true;}
  bool is_numeric_type(void) const {return false;}

  bool valid_as_scalar_index(void) const {return false;}

  bool is_true(void) const { return true; }
   
private:
  GiNaC::symbol x;

  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA  

};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
