#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright 2014-2016 Colin B. Macdonald
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

"""generate_functions.py

Yo dawg, I heard you like code generation so I wrote a code
generator to write your code generators!
"""

import sys
import os
import sympy as sp

input_list = \
"""
exp
log
sqrt|||exp(x)
cbrt||2,1.2599210498948731647||2015
abs|Abs|-1
floor
ceil|ceiling|3/2
sin
sinh
asin
asinh
cos
cosh
acos
acosh
tan
tanh
atan
atanh||1/2
csc
sec
acsc||||2016
asec||2||2016
csch||||2016
acsch||||2016
sech||||2016
asech||1/2||2016
cot
coth
acot
acoth||2
sign
factorial
gamma
erf
erfc
erfinv||1/2
erfcinv
erfi||0,0|
dirac|DiracDelta
cosint|Ci|1,0.3374039229009681346626||2016
sinint|Si|1,0.9460830703671830149414||2016
coshint|Chi|1,0.8378669409802082408947||2016
sinhint|Shi|1,1.057250875375728514572||2016
logint|li|2,1.045163780117492784845||2016
zeta||2,pi^2/6||2016
"""


# These functions need numerical implementations.  Don't list things here
# that have native implementations in Octave or Symbolic!
numerical_list = \
"""
coshint|Chi
sinhint|Shi
cosint|Ci
sinint|Si
fresnelc
fresnels
logint|li
zeta
"""


license_boilerplate = \
"""%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.
"""


def process_input_list(L):
    """replace L with a list of dictionaries"""
    LL = L.splitlines()
    L = []
    for it in LL:
        if len(it) == 0:
            continue
        it = it.split('|')
        f = it[0]
        d = {'name':f}
        if len(it) >= 2 and it[1] != '':
            d['spname'] = it[1]
        else:
            d['spname'] = f
        if len(it) >= 3 and it[2] != '':
            testvals = it[2].split(',')
            if len(testvals) == 2:
                (d['test_in_val'],d['test_out_val']) = testvals
                d['out_val_from_oct'] = False
            else:
                (d['test_in_val'],) = testvals
                d['out_val_from_oct'] = True
                d['octname'] = f
        else:
            d['test_in_val'] = '1'
            d['out_val_from_oct'] = True
            d['octname'] = f
        if (len(it) >= 4) and it[3] != '':
            d['docexpr'] = it[3]
        else:
            d['docexpr'] = 'x'
        if (len(it) >= 5):
            d['firstyear'] = int(it[4])
        else:
            d['firstyear'] = 2014
        L.append(d)
    return L


def process_numerical_list(L):
    """replace L with a list of dictionaries"""
    LL = L.splitlines()
    L = []
    for it in LL:
        if len(it) == 0:
            continue
        it = it.split('|')
        f = it[0]
        d = {'name':f}
        if len(it) > 1 and it[1] != '':
            d['spname'] = it[1]
        else:
            d['spname'] = f
        if len(it) > 2:
            d['firstyear'] = int(it[2])
        else:
            d['firstyear'] = 2016
        L.append(d)
    return L


def remove_all(L):
    """all a bit hacky, should do better"""
    for d in L:
        f = d['name']
        fname = '../inst/@sym/%s.m' % f
        try:
            os.unlink(fname)
        except:
            True


def make_copyright_line(firstyear):
    import datetime
    now = datetime.datetime.now()
    thisyear = now.year
    if (thisyear - firstyear == 0):
        copyright_years = "%d" % thisyear
    elif (thisyear - firstyear >= 1):
        copyright_years = "%d-%d" % (firstyear, thisyear)
    else:
        raise ValueError('wtf')
    return "%% Copyright (C) " + copyright_years + " Colin B. Macdonald\n"


def autogen_functions(L, where):
    for d in L:
        f = d['name']
        fname = '%s/@sym/%s.m' % (where,f)
        print fname

        fd = open(fname, "w")

        fd.write(make_copyright_line(d['firstyear']))
        fd.write("%%\n")

        fd.write(license_boilerplate)

        # Build and out example block for doctest
        xstr = d['docexpr']
        x = sp.S(xstr)
        y = eval("sp.%s(x)" % d['spname'])
        ystr = sp.pretty(y, use_unicode=True)
        lines = ystr.splitlines()
        if len(lines) > 1:
            # indent multiline output
            lines = [("%%       " + a).strip() for a in lines]
            ystr = "\n" + "\n".join(lines)
        else:
            ystr = " " + ystr
        yutf8 = ystr.encode('utf-8')

        body = \
"""
%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod @@sym {NAME} (@var{{x}})
%% Symbolic {NAME} function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = {NAME} ({XSTR})
%%   @result{{}} y = (sym){YUTF8}
%% @end group
%% @end example
%%
%% Note: this file is autogenerated: if you want to edit it, you might
%% want to make changes to 'generate_functions.py' instead.
%%
%% @end defmethod


function y = {NAME}(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = op_helper ('{SPNAME}', x);
end


%!error <Invalid> {NAME} (sym(1), 2)
%!assert (isequaln ({NAME} (sym(nan)), sym(nan)))

""".format(NAME=f, SPNAME=d['spname'], XSTR=xstr, YUTF8=yutf8)

        fd.write(body)

        # tests
        fd.write("%!shared x, d\n")
        fd.write("%%! d = %s;\n" % d['test_in_val'])
        fd.write("%%! x = sym('%s');\n\n" % d['test_in_val'])
        fd.write("%!test\n")
        fd.write("%%! f1 = %s(x);\n" % f)
        if d['out_val_from_oct']:
            fd.write("%%! f2 = %s(d);\n" % f)
        else:
            fd.write("%%! f2 = %s;\n" % d['test_out_val'])
        fd.write("%! assert( abs(double(f1) - f2) < 1e-15 )\n\n")

        fd.write("%!test\n")
        fd.write("%! D = [d d; d d];\n")
        fd.write("%! A = [x x; x x];\n")
        fd.write("%%! f1 = %s(A);\n" % f)
        if d['out_val_from_oct']:
            fd.write("%%! f2 = %s(D);\n" % f)
        else:
            fd.write("%%! f2 = %s;\n" % d['test_out_val'])
            fd.write("%! f2 = [f2 f2; f2 f2];\n")
        fd.write("%! assert( all(all( abs(double(f1) - f2) < 1e-15 )))\n")

        fd.write( \
"""
%!test
%! % round trip
%! y = sym('y');
%! A = {NAME} (d);
%! f = {NAME} (y);
%! h = function_handle (f);
%! B = h (d);
%! assert (A, B, -eps)
""".format(NAME=f))

        fd.close()


def autogen_numerical_functions(L, where):
    for d in L:
        make_numerical_fcn(d, where)


def make_numerical_fcn(d, where):
    f = d['name']
    fname = '%s/%s.m' % (where,f)
    print fname

    fd = open(fname, "w")

    fd.write(make_copyright_line(d['firstyear']))
    fd.write("%%\n")

    fd.write(license_boilerplate)

    numresult = eval("sp.%s(1.1)" % d['spname'])
    numresult = "%.5g" % numresult

    body = \
"""
%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defun {NAME} (@var{{x}})
%% Numerical {NAME} function.
%%
%% Example:
%% @example
%% @group
%% {NAME} (1.1)
%%   @result{{}} ans = {NUMRESULT}
%% @end group
%% @end example
%%
%% @strong{{Note}} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the SymPy function
%% @code{{{SPNAME}}}.
%%
%% Note: this file is autogenerated: if you want to edit it, you might
%% want to make changes to 'generate_functions.py' instead.
%%
%% @seealso{{@@sym/{NAME}}}
%% @end defun


function y = {NAME} (x)
  if (nargin ~= 1)
    print_usage ();
  end
  cmd = {{ 'L = _ins[0]'
          'A = [complex({SPNAME}(complex(x))) for x in L]'
          'return A,' }};
  c = python_cmd (cmd, num2cell(x(:)));
  assert (numel (c) == numel (x))
  y = x;
  for i = 1:numel (c)
    y(i) = c{{i}};
  end
end


%!test
%! x = 1.1;
%! y = sym(11)/10;
%! A = {NAME} (x);
%! B = double ({NAME} (y));
%! assert (A, B, -4*eps);

%!test
%! y = [2 3 sym(pi); exp(sym(1)) 5 6];
%! x = double (y);
%! A = {NAME} (x);
%! B = double ({NAME} (y));
%! assert (A, B, -4*eps);
""".format(NAME=f, SPNAME=d['spname'], NUMRESULT=numresult)

    fd.write(body)

    fd.close()


def print_usage():
    print """
  Run this script with one argument:
    python generate_functions install:  make m files in ../inst/@sym
    python generate_functions clean:  remove them from above
"""

if __name__ == "__main__":
    L = process_input_list(input_list)
    Lnum = process_numerical_list(numerical_list)
    print sys.argv
    if len(sys.argv) <= 1:
        print_usage()
    elif sys.argv[1] == 'install':
        print "***** Generating numerical .m file code ****"
        autogen_numerical_functions(Lnum, '../inst/@double')
        print "***** Generating code for .m files from template ****"
        autogen_functions(L, '../inst')
    elif sys.argv[1] == 'clean':
        print "cleaning up"
        remove_all(L)
    else:
        print_usage()


