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

#if !defined (octave_relational_h)
#define octave_relational_h 1

// GiNaC
#include <ginac/ginac.h>
#include <octave/ov-base.h>
#include "ov-ex.h"

// relational values.

class
octave_relational : public octave_base_value
{
public:

  octave_relational (void):octave_base_value() {}
  
  octave_relational (GiNaC::relational & orel) : octave_base_value () { rel = orel;}

  octave_relational (const GiNaC::ex & lhs, 
		   const GiNaC::ex & rhs, 
		   GiNaC::relational::operators op);

  octave_relational (const octave_ex & lhs, 
		   const octave_ex & rhs, 
		   GiNaC::relational::operators op);

  octave_relational (const octave_ex & lhs, 
		   const GiNaC::ex & rhs, 
		   GiNaC::relational::operators op);

  octave_relational (const GiNaC::ex & lhs, 
		   const octave_ex & rhs, 
		   GiNaC::relational::operators op);

  ~octave_relational (void) { }

  octave_value *clone (void) { return new octave_relational (*this); }

  int rows (void) const { return 1; }
  int columns (void) const { return 1; }

  bool is_constant (void) const { return true; }

  bool is_defined (void) const { return true; }

  octave_value all (void) const { return (double) bool(rel); }
  octave_value any (void) const { return (double) bool(rel); }

  bool is_true (void) const { return bool(rel); }

  GiNaC::relational relational_value (bool = false) const { return rel; }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const;

private:
  
  GiNaC::relational rel;

  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
