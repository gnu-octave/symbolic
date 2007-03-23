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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

*/

// 2003-05-1 Willem Atsma <watsma@users.sf.net>
// * Modified the constructors and the destructor and added a symbol list
//   and symbol reference count. New members are:
//        void assign_symbol_to_list(GiNaC::symbol &sym);
//        class symbol_list_item;
//        static std::vector<symbol_list_item> symbol_list;
//   This is a work-around for the fact that GiNaC can have different symbols
//   with the same string name, while in octave you want a symbol that
//   appears the same to actually be the same. It works great as long as
//   symbols are declared in octave. It is still possible to have same-name
//   symbols that are different to GiNaC, if a symbol goes out of scope in
//   octave without it being defined in octave's workspace. This could be fixed
//   by also keeping reference counts for symbols in expressions.


#include <octave/config.h>
#include <ginac/ginac.h>
#include "ov-ex.h"
#include "ov-vpa.h"

std::vector<octave_ex::symbol_list_item> octave_ex::symbol_list;

// A list of symbols is maintained to ensure all symbols that look the
// same in octave are in fact the same to GiNaC. The destructor removes
// items if the reference count goes to zero.
void octave_ex::assign_symbol_to_list(GiNaC::symbol &sym)
{
	unsigned int i;
	std::string name = sym.get_name();
	// check if new symbol already exists
	for(i=0;i<symbol_list.size();i++) {
		if(symbol_list[i].sym.get_name() == name) {
			symbol_list[i].refcount++;
			sym = symbol_list[i].sym;
			return;
		}
	}
	// add new symbol to list
	symbol_list_item new_item(sym,1);
	symbol_list.push_back(new_item);
}

octave_ex::octave_ex(octave_ex &ox)
{
  if(GiNaC::is_a<GiNaC::symbol>(ox.x)) {
  	GiNaC::symbol sym = GiNaC::ex_to<GiNaC::symbol>(ox.x);
	assign_symbol_to_list(sym);
	x = sym;
  } else
    x = ox.x;
}

octave_ex::octave_ex(GiNaC::ex expression)
{
  if(GiNaC::is_a<GiNaC::symbol>(expression)) {
  	GiNaC::symbol sym = GiNaC::ex_to<GiNaC::symbol>(expression);
	assign_symbol_to_list(sym);
	x = sym;
  } else
    x = expression;
}

octave_ex::octave_ex(GiNaC::symbol sym)
{
	assign_symbol_to_list(sym);
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

// If this is a symbol, remove list entry if it exists.
octave_ex::~octave_ex()
{
	if((GiNaC::is_a<GiNaC::symbol>(x)) && (!symbol_list.empty())) {
		GiNaC::symbol sym = GiNaC::ex_to<GiNaC::symbol>(x);
		std::vector<symbol_list_item>::iterator iter_symlist;
		for(iter_symlist=symbol_list.begin();iter_symlist<symbol_list.end();) {
		  if(GiNaC::operator == (sym, iter_symlist->sym)) {
				iter_symlist->refcount --;
				if(iter_symlist->refcount==0) {
					iter_symlist = symbol_list.erase(iter_symlist);
					continue;
				}
			}
		  iter_symlist++;
		}
	}
}

void 
octave_ex::print(std::ostream& os,bool pr_as_read_syntax) const
{
  os << x;
}

 
octave_ex& octave_ex::operator=(const octave_ex& a)
{
  return (*(new octave_ex(a.x)));
}

DEFINE_OCTAVE_ALLOCATOR (octave_ex);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_ex, "ex", "sym");

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
