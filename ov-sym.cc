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
#include "ov-ex.h"
#include "ov-sym.h"

// class ostream;

octave_sym::octave_sym(char *str)
{
  x = GiNaC::symbol(str);
}

GiNaC::symbol 
octave_sym::sym_value() const 
{
  return x;
}

octave_value 
octave_sym::uminus (void)
{
  return (new octave_ex(-x));
} 
  
void 
octave_sym::print(std::ostream& os,bool pr_as_read_syntax) const
{
  os << x;
}

DEFINE_OCTAVE_ALLOCATOR (octave_sym);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_sym, "sym");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
