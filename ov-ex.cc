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
#include <ginac/ginac.h>
#include "ov-ex.h"
#include "ov-sym.h"
#include "ov-vpa.h"

octave_ex::octave_ex(octave_ex &ox)
{
  x = ox.x;
}

octave_ex::octave_ex(GiNaC::ex expression)
{
  x = expression;
}

octave_ex::octave_ex(octave_sym &osym) 
{
  x = osym.sym_value () + 0; 
}

octave_ex::octave_ex(GiNaC::symbol sym)
{
  x = sym;
}

octave_ex::octave_ex(octave_complex &cmplx)
{
  Complex z = cmplx.complex_value (); 
  x = z.real () + GiNaC::I*z.imag ();
}

octave_ex::octave_ex(Complex z)
{
  x = z.real () + GiNaC::I*z.imag ();
}

octave_ex::octave_ex(octave_scalar &s)
{
  double d = s.double_value (); 
  x = d;
}

octave_ex::octave_ex(double d)
{
  x = d;
}

void 
octave_ex::print(ostream& os,bool pr_as_read_syntax) const
{
  os << x;
}

 
octave_ex& octave_ex::operator=(const octave_ex& a)
{
  return (*(new octave_ex(a.x)));
}

DEFINE_OCTAVE_ALLOCATOR (octave_ex);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_ex, "ex");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
