## Copyright (C) 2003 Willem J. Atsma
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation;
## either version 2, or (at your option) any later version.
##
## This software is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public
## License along with this software; see the file COPYING.  If not,
## write to the Free Software Foundation, 51 Franklin Street, 
## Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{c} = sym2poly (@var{p}, @var{x})
## Returns the coefficients of the symbolic polynomial expression @var{p}
## as a vector. If there is only one free variable in @var{p} the
## coefficient vector @var{c} is a plain numeric vector. If there is more
## than one free variable in @var{p}, a second argument @var{x} specifies the
## free variable and the function returns a list of symbolic expressions.
## The coefficients correspond to decreasing exponent of the free variable.
##
## Example:
## @example
## symbols
## x=sym("x"); y=sym("y");
## c = sym2poly (x^2+3*x-4);    # c = [2,3,-4]
## c = sym2poly (x^2+y*x,x);    # c = list(2,y,0)
## @end example
##
## If @var{p} is not a polynomial the result has no warranty.
##
## @end deftypefn
## @seealso{poly2sym,polyval,roots}

## Author: Willem J. Atsma <watsma(at)users.sf.net>
## Created: 18 April 2003
## Changed: 25 April 2003
##    Removed the use of differentiate to get to coefficients - round-off
##     errors cause problems. Now using newly created sumterms().
## Changed: 6 May 2003
##    Removed the attempt to use ldegree(), degree() and coeff() - results
##     with these are inconsistent.

function c = sym2poly(p,x)

BADPOLY_COEFF_LIMIT = 500;

if is_vpa(p)
	# polynomial is one vpa number
	c = to_double(p);
	if length(c)!=1
		error("Argument is not a polynomial.");
	endif
	return
endif

if !is_ex(p)
	error("Argument has to be a symbolic expression.")
endif

pvars = findsymbols(p);
if isempty(pvars)
	# It is possible that we get an expression without any symbols.
	c = to_double(p);
	return;
endif
nvars = length(pvars); 

if nvars>1 & exist("x")!=1
	error("Symbolic expression has more than 1 free variable; no variable specified.")
elseif exist("x")!=1
	x = pvars{1};
endif

p = expand(p);

## GiNaC has commands to access coefficients directly, but in octave this often
## does not work, because for example x^2 typed in octave results in a 
## non-integer power in GiNaC: x^2.0 .

[num,den] = numden(p);
tmp = findsymbols(den);
for i=1:length(tmp)
	if tmp{i}==x
		error("Symbolic expression is a ratio of polynomials.")
	endif
endfor

p = expand(p);
p_terms = sumterms(p);
# if this is well behaved, I can find the coefficients by dividing with x
c_ex = list;
for i=1:length(p_terms)
	tmp = p_terms{i};
	for j=1:BADPOLY_COEFF_LIMIT
		if disp(differentiate(tmp,x))=="0"
			break;
		endif
		tmp = tmp/x;
	endfor
	if j==BADPOLY_COEFF_LIMIT
		printf("Please examine your code or adjust this function.\n");
		printf("This error may occur because the passed expression is not a polynomial.\n");
		error("Reached the set limit (%d) for the number of coefficients.",BADPOLY_COEFF_LIMIT)
	endif
	if (length(c_ex)<j) || isempty(c_ex{j})
		c_ex(j)=tmp;
	else
		c_ex(j) = c_ex{j}+tmp;
	endif		
endfor
order = length(c_ex)-1;

all_numeric = true;
for i=1:(order+1)
	if isempty(c_ex{i})
		c_ex(i) = vpa(0);
	endif
	cvar=findsymbols(c_ex{i});
	ncvar = length(cvar);
	if ncvar
		all_numeric=false;
		for j=1:ncvar
			if disp(cvar{j})==disp(x)
				printf("Possibly this error occurs because two symbols with the same name\n");
				printf("are different to GiNaC. Make sure the free variable exists as a\n");
				printf("symbol in your workspace.\n");
				error("The symbolic expression is not a polynomial.")
			endif
		endfor
	endif
endfor

c_ex = reverse(c_ex);

if all_numeric
	for i=1:(order+1)
		c(1,i)=to_double(c_ex{i});
	endfor
else
	c = c_ex;
endif
