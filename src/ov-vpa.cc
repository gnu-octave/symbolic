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

#include <octave/config.h>
#include "ov-vpa.h"

// class ostream;

octave_vpa::octave_vpa(void):octave_base_value()
{
  scalar = GiNaC::numeric(0);
}

octave_vpa::octave_vpa (int i):octave_base_value()
{ 
  scalar = GiNaC::numeric(0);
}

octave_vpa::octave_vpa (const octave_vpa& s):octave_base_value()
{ 
  scalar = s.scalar;
}
  
octave_vpa::octave_vpa (const GiNaC::numeric& s):octave_base_value()
{
  scalar = s;
}
  
octave_vpa::octave_vpa( const GiNaC::ex& x):octave_base_value()
{
  scalar = GiNaC::ex_to<GiNaC::numeric>(x);
}

void
octave_vpa::print (std::ostream& os, bool pr_as_read_syntax) const
{
  os << scalar;
}

DEFINE_OCTAVE_ALLOCATOR (octave_vpa);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_vpa, "vpa", "sym");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
