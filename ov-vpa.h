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

#if !defined (octave_vpa_h)
#define octave_vpa_h 1

// GiNaC
#include <ginac/ginac.h>
#include <octave/ov-base.h>

// vpa values.

class
octave_vpa : public octave_base_value
{
public:

  octave_vpa (void);  
  octave_vpa (int i);
  octave_vpa (const octave_vpa& s);
  octave_vpa (const GiNaC::numeric& s);
  octave_vpa( const GiNaC::ex& x);

  ~octave_vpa (void) { }

  octave_value *clone (void) { return new octave_vpa (*this); }

#if 0
  void *operator new (size_t size);
  void operator delete (void *p, size_t size);
#endif 

#ifdef HAVE_ND_ARRAYS
  dim_vector dims (void) const { static dim_vector dv (1, 1); return dv; }
#endif
  int rows (void) const { return 1; }
  int columns (void) const { return 1; }

  bool is_constant (void) const { return true; }

  bool is_defined (void) const { return true; }
  bool is_real_scalar (void) const { return true; }

  octave_value all (void) const { return (double) (scalar != 0); }
  octave_value any (void) const { return (double) (scalar != 0); }

  bool is_real_type (void) const { return true; }
  bool is_scalar_type (void) const { return true; }
  bool is_vpa_type (void) const { return true; }

  bool valid_as_scalar_index (void) const
    { return scalar == 1; }

  bool valid_as_zero_index (void) const
    { return scalar == 0; }

  bool is_true (void) const { return (scalar != 0); }

  double double_value (bool = false) const { return scalar.to_double(); }

  GiNaC::numeric vpa_value (bool = false) const { return scalar; }

  octave_value hermitian (void) const { return new octave_vpa (scalar); }

  void increment (void) { ++scalar; }

  void decrement (void) { --scalar; }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const;

private:
  
  GiNaC::numeric scalar;

  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

