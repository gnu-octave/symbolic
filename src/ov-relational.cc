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
#include "ov-relational.h"

octave_relational::octave_relational (const GiNaC::ex & lhs, 
				  const GiNaC::ex & rhs, 
				  GiNaC::relational::operators op=GiNaC::relational::equal)
{
  rel = GiNaC::relational(lhs, rhs, op);
}

octave_relational::octave_relational (const octave_ex & lhs, 
				  const octave_ex & rhs, 
				  GiNaC::relational::operators op=GiNaC::relational::equal)
{
  rel = GiNaC::relational(lhs.ex_value (), rhs.ex_value (), op);
}

octave_relational::octave_relational (const octave_ex & lhs, 
				  const GiNaC::ex & rhs, 
				  GiNaC::relational::operators op=GiNaC::relational::equal)
{
  rel = GiNaC::relational(lhs.ex_value (), rhs, op);
}

octave_relational::octave_relational (const GiNaC::ex & lhs, 
				  const octave_ex & rhs, 
				  GiNaC::relational::operators op=GiNaC::relational::equal)
{
  rel = GiNaC::relational(lhs, rhs.ex_value (), op); 
}

void
octave_relational::print (std::ostream& os, bool pr_as_read_syntax) const
{
  GiNaC::print_context pr(os);

  rel.print(pr);
}


DEFINE_OCTAVE_ALLOCATOR (octave_relational);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_relational, "relational", "sym");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
