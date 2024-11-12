# Copyright (C) 2014-2017, 2019, 2021-2024 Colin B. Macdonald
# Copyright (C) 2019 Mike Miller
# Copyright (C) 2020 Tianyu Chen (billchenchina)
# Copyright (C) 2021 Johannes Maria Frank
# Copyright (C) 2022 Chris Gorman
# Copyright (C) 2022 Alex Vong
# SPDX-License-Identifier: GPL-3.0-or-later

# In some cases this code is fed into stdin: two blank lines between
# try-except blocks, no blank lines within each block.
#
# Maintenance note: this code is largely duplicated with python_ipc_native
# Ensure both are updated!

import sys

sys.ps1 = ""; sys.ps2 = ""


def echo_exception_stdout(mystr):
    exception_str = sys.exc_info()[0].__name__ + ": " + str(sys.exc_info()[1])
    # hardcode xml, we may not have imports yet.  1003 is code for string.
    print("<output_block>\n<list>")
    print("<item>\n<f>1003</f>\n<f>INTERNAL_PYTHON_ERROR</f>\n</item>")
    print("<item>\n<f>1003</f>")
    print("<f>" + mystr.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") + "</f>\n</item>")
    print("<item>\n<f>1003</f>")
    print("<f>" + exception_str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") + "</f>\n</item>")
    print("</list>\n</output_block>\n")

try:
    import sympy
    import mpmath
    import sympy as sp
    from sympy import __version__ as spver
    from re import split as lib_re_split
    # need this to reactivate from srepr
    from sympy import *
    from sympy.logic.boolalg import Boolean, BooleanFunction
    from sympy.core.relational import Relational
    # temporary? for piecewise support
    from sympy.functions.elementary.piecewise import ExprCondPair
    from sympy.integrals.risch import NonElementaryIntegral
    from sympy.matrices.expressions.matexpr import MatrixElement
    # for hypergeometric
    from sympy.functions.special.hyper import TupleArg
    # for sets
    from sympy.utilities.iterables import uniq
    try:
        # quick fix for https://github.com/gnu-octave/symbolic/issues/1053
        # TODO: investigate the sym ctor in this case, likely a better fix in there
        from sympy.core.symbol import Str
    except ImportError:
        pass
    import copy
    import binascii
    import struct
    import codecs
    import xml.etree.ElementTree as ET
    try:
        from packaging.version import Version
    except ImportError:
        try:
            # available on SymPy >= 1.9
            from sympy.external.importtools import version_tuple as Version
        except ImportError:
            # will fail on Python 3.12: drop this soon in favour of above
            from distutils.version import LooseVersion
            def Version(v):
                return LooseVersion(v.replace('.dev', ''))
    import itertools
    import collections
    # patch pretty printer, issue #952
    try:
        from sympy.printing.pretty.pretty import PrettyPrinter
        _mypp = PrettyPrinter
    except:
        # is this needed for SymPy 1.4?  TODO: Bump minimum SymPy and cleanup
        _mypp = pretty.__globals__["PrettyPrinter"]
    def _my_rev_print(cls, f, **kwargs):
        g = f.func(*reversed(f.args), evaluate=False)
        return cls._print_Function(g, **kwargs)
    _mypp._print_LambertW = lambda cls, f: _my_rev_print(cls, f, func_name='lambertw')
    _mypp._print_sinc = lambda cls, f: cls._print_Function(f.func(f.args[0]/sp.pi, evaluate=False))
    del _mypp
except:
    echo_exception_stdout("in python_header import block")
    raise


try:
    def dbout(l):
        # should be kept in sync with the same function
        # defined in inst/private/python_ipc_native.m
        sys.stderr.write("pydebug: " + str(l) + "\n")
    def d2hex(x):
        # used to pass doubles back-and-forth
        return binascii.hexlify(struct.pack(">d", x)).decode()
    def hex2d(s):
        bins = bytes([int(s[x:x+2], 16) for x in range(0, len(s), 2)])
        return struct.unpack(">d", bins)[0]
    def myesc(s):
        # workaround https://bugs.python.org/issue25270
        if not s:
            return s
        b, _ = codecs.escape_encode(s.encode('utf-8'))
        return b.decode('ascii')
except:
    echo_exception_stdout("in python_header defining fcns block 1")
    raise


try:
    def objectfilter(x):
        """Perform final fixes before passing objects back to Octave"""
        if isinstance(x, sp.Matrix) and x.shape == (1, 1):
            return x[0, 0]
        #elif isinstance(x, sp.MatrixExpr):
        #    return x.doit()
        return x
    #
    def octoutput_drv(x, tostdout=True):
        xroot = ET.Element("output_block")
        octoutput(x, xroot)
        # simple, but no newlines and escapes unicode
        #print(ET.tostring(xroot))
        #print("\n")
        # Clashes with some expat lib in Matlab, Issue #63
        import xml.dom.minidom as minidom
        DOM = minidom.parseString(ET.tostring(xroot))
        # want real newlines here (so hard to do escaping *after* this)
        s = DOM.toprettyxml(indent="", newl="\n")
        if tostdout:
            print(s)
        else:
            return s
except:
    echo_exception_stdout("in python_header defining fcns block 3")
    raise


try:
    def octoutput(x, et):
        OCTCODE_INT = 1001
        OCTCODE_DOUBLE = 1002
        OCTCODE_STR = 1003
        OCTCODE_BOOL = 1005
        OCTCODE_COMPLEX = 1006
        OCTCODE_DICT = 1010
        OCTCODE_SYM = 1020
        x = objectfilter(x)
        if isinstance(x, bool):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_BOOL)
            f = ET.SubElement(a, "f")
            f.text = str(x)
        elif x is None or isinstance(x, (sp.Basic, sp.MatrixBase, sp.NDimArray)):
            # FIXME: is it weird to pretend None is a SymPy object?
            if isinstance(x, (sp.Matrix, sp.ImmutableMatrix)):
                _d = x.shape
            elif isinstance(x, sp.MatrixExpr):
                # nan for symbolic size
                _d = [float(r) if (isinstance(r, sp.Basic) and r.is_Integer)
                      else float('nan') if isinstance(r, sp.Basic)
                      else r for r in x.shape]
            elif isinstance(x, sp.NDimArray):
                _d = x.shape
                dbout(f"I am here with an array with shape {_d}")
            elif x is None:
                _d = (1,1)
            else:
                _d = (1, 1)
            try:
                pretty_ascii = sp.pretty(x, use_unicode=False)
            except:
                # e.g., SymPy issue #10414
                pretty_ascii = str(x)
            pretty_unicode = sp.pretty(x, use_unicode=True)
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_SYM)
            f = ET.SubElement(a, "f")
            f.text = sympy.srepr(x)
            f = ET.SubElement(a, "f")
            f.text = str(_d[0])
            f = ET.SubElement(a, "f")
            f.text = str(_d[1])
            f = ET.SubElement(a, "f")
            f.text = str(x)  # esc?
            f = ET.SubElement(a, "f")
            f.text = myesc(pretty_ascii)
            f = ET.SubElement(a, "f")
            f.text = myesc(pretty_unicode)
        elif isinstance(x, (list, tuple)):
            c = ET.SubElement(et, "list")
            for y in x:
                octoutput(y, c)
        elif isinstance(x, int):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_INT)
            f = ET.SubElement(a, "f")
            f.text = str(x)
        elif isinstance(x, float):
            # We pass IEEE doubles using the exact hex representation
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_DOUBLE)
            f = ET.SubElement(a, "f")
            f.text = d2hex(x)
        elif isinstance(x, complex):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_COMPLEX)
            f = ET.SubElement(a, "f")
            f.text = d2hex(x.real)
            f = ET.SubElement(a, "f")
            f.text = d2hex(x.imag)
        elif isinstance(x, str):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_STR)
            f = ET.SubElement(a, "f")
            f.text = myesc(x)
        elif isinstance(x, dict):
            # Note: the dict cannot be too complex, keys must convert to
            # strings for example.  Values can be dicts, lists.
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_DICT)
            # Convert keys to strings
            keystr = [str(y) for y in x.keys()]
            c = ET.SubElement(a, "list")
            octoutput(keystr, c)
            c = ET.SubElement(a, "list")
            # FIXME: bit of a kludge, use iterable instead of list, tuple above?
            octoutput(list(x.values()), c)
        else:
            raise ValueError("octoutput does not know how to export type " + str(type(x)))
except:
    echo_exception_stdout("in python_header defining fcns block 4")
    raise


try:
    def make_matrix_or_array(it_of_it, dbg_no_array=False):
        # should be kept in sync with the same function
        # defined in inst/private/python_ipc_native.m
        # FIXME: dbg_no_array is currently used for debugging,
        # remove it once sympy drops non-Expr supp in Matrix
        """
        Given an iterable of iterables of syms IT_OF_IT
        If all elements of IT_OF_IT are Expr,
        construct the corresponding Matrix.
        Otherwise, construct the corresponding 2D array.
        """
        ls_of_ls = [[elt for elt in it] for it in it_of_it]
        elts = flatten(ls_of_ls, levels=1)
        if (dbg_no_array
            or all(isinstance(elt, Expr) for elt in elts)):
            return Matrix(ls_of_ls)
        else:
            dbout(f"make_matrix_or_array: making 2D Array...")
            return Array(ls_of_ls)
except:
    echo_exception_stdout("in python_header defining fcns block 5")
    raise
# end of python header, now couple blank lines


