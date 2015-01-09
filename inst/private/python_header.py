# Part of OctSymPy.
# In some cases this code is fed into stdin: two blank lines between
# try-except blocks, no blank lines within each block.

from __future__ import print_function
from __future__ import division

import sys
sys.ps1 = ""; sys.ps2 = ""


def myerr(e):
    # hardcoded in case no xml
    print("<output_block>")
    print("<item>\n<f>9999</f>\n<f>")
    print(str(e[0]).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))
    print("</f><f>")
    print(str(e[1]).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))
    print("</f>\n</item>")
    print("</output_block>\n")


try:
    import sympy
    import sympy as sp
    # need this to reactivate from srepr
    from sympy import *
    import sympy.printing
    from sympy.logic.boolalg import Boolean, BooleanFunction
    from sympy.core.relational import Relational
    # temporary? for piecewise support
    from sympy.functions.elementary.piecewise import ExprCondPair
    import copy
    import binascii
    import struct
    import xml.etree.ElementTree as ET
except:
    myerr(sys.exc_info())
    raise


try:
    def dbout(l):
        sys.stderr.write("pydebug: " + str(l) + "\n")
    def d2hex(x):
        # used to pass doubles back-and-forth
        return binascii.hexlify(struct.pack(">d", x))
    def hex2d(s):
        bins = "".join(chr(int(s[x:x+2], 16)) for x in range(0, len(s), 2))
        return struct.unpack(">d", bins)[0]
    def dictdiff(a, b):
        """ keys from a that are not in b, used by evalpy() """
        n = dict()
        for k in a:
            if not k in b:
                n[k] = a[k]
        return n
except:
    myerr(sys.exc_info())
    raise


try:
    class _ReprPrinter_w_asm(sympy.printing.repr.ReprPrinter):
        def _print_Symbol(self, expr):
            asm = expr.assumptions0
            # Not strictly necessary but here are some common cases so we
            # can abbreviate them.  Even better would be some
            # "minimal_assumptions" code, but I did not see such a thing.
            asm_default = {"commutative":True}
            asm_real = {"commutative":True, "complex":True, "hermitian":True,
                        "imaginary":False, "real":True}
            asm_pos = {"commutative":True, "complex":True, "hermitian":True,
                       "imaginary":False, "negative":False, "nonnegative":True,
                       "nonpositive":False, "nonzero":True, "positive":True,
                       "real":True, "zero":False}
            asm_neg = {"commutative":True, "complex":True, "hermitian":True,
                       "imaginary":False, "negative":True, "nonnegative":False,
                       "nonpositive":True, "nonzero":True, "positive":False,
                       "prime":False, "composite":False, "real":True,
                       "zero":False}
            if asm == asm_default:
                xtra = ""
            elif asm == asm_real:
                xtra = ", real=True"
            elif asm == asm_pos:
                xtra = ", positive=True"
            elif asm == asm_neg:
                xtra = ", negative=True"
            else:
                xtra = ""
                for (key, val) in asm.iteritems():
                    xtra = xtra + ", %s=%s" % (key, val)
            return "%s(%s%s)" % (expr.__class__.__name__,
                                 self._print(expr.name), xtra)
    #
    def my_srepr(expr, **settings):
        """return expr in repr form w/ assumptions listed"""
        return _ReprPrinter_w_asm(settings).doprint(expr)
except:
    myerr(sys.exc_info())
    raise



try:
    def objectfilter(x):
        """Perform final fixes before passing objects back to Octave"""
        if isinstance(x, sp.Matrix) and x.shape == (1, 1):
            return x[0, 0]
        elif isinstance(x, sp.MatrixExpr):
            try:
                # expands MatPow(A, 2) and known-size MatrixSymbols
                y = x.as_explicit()
                if sympy.__version__ == "0.7.5" and any([p is None for p in y]):
                    raise NotImplementedError()
                return y
            except:
                return x
        return x
    #
    def octoutput_drv(x):
        xroot = ET.Element("output_block")
        octoutput(x, xroot)
        # simple, but no newlines and escapes unicode
        #print(ET.tostring(xroot))
        #print("\n")
        # Clashes with some expat lib in Matlab, Issue #63
        import xml.dom.minidom as minidom
        DOM = minidom.parseString(ET.tostring(xroot))
        print(DOM.toprettyxml(indent="", newl="\n", encoding="utf-8"))
except:
    myerr(sys.exc_info())
    raise


try:
    # FIXME: unicode may not have enough escaping, but cannot string_escape
    def octoutput(x, et):
        OCTCODE_INT = 1001
        OCTCODE_DOUBLE = 1002
        OCTCODE_STR = 1003
        OCTCODE_USTR = 1004
        OCTCODE_BOOL = 1005
        OCTCODE_DICT = 1010
        OCTCODE_SYM = 1020
        x = objectfilter(x)
        if isinstance(x, bool):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_BOOL)
            f = ET.SubElement(a, "f")
            f.text = str(x)
        elif isinstance(x, (sp.Basic, sp.Matrix, sp.MatrixExpr)):
            if isinstance(x, (sp.Matrix, sp.ImmutableMatrix)):
                _d = x.shape
            elif isinstance(x, (sp.Expr, Boolean)):
                _d = (1, 1)
            elif isinstance(x, sp.MatrixExpr):
                # FIXME: play with x.shape instead
                _d = (1, 1)
            else:
                dbout("Treating unexpected SymPy obj as scalar: " + str(type(x)))
                _d = (1,1)
            pretty_ascii = sp.pretty(x, use_unicode=False)
            pretty_unicode = sp.pretty(x, use_unicode=True)
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_SYM)
            f = ET.SubElement(a, "f")
            f.text = my_srepr(x)
            f = ET.SubElement(a, "f")
            f.text = str(_d[0])
            f = ET.SubElement(a, "f")
            f.text = str(_d[1])
            f = ET.SubElement(a, "f")
            f.text = str(x)
            f = ET.SubElement(a, "f")
            f.text = pretty_ascii
            f = ET.SubElement(a, "f")
            f.text = pretty_unicode
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
        elif isinstance(x, str):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_STR)
            f = ET.SubElement(a, "f")
            f.text = x
        elif isinstance(x, unicode):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_USTR)
            f = ET.SubElement(a, "f")
            # newlines are ok with new regexp parser
            #f.text = x.replace("\n","\\n")
            f.text = x
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
            octoutput(x.values(), c)
        else:
            dbout("error exporting variable:")
            dbout("x: " + str(x))
            dbout("type: " + str(type(x)))
            octoutput("python does not know how to export type " + str(type(x)), et)
except:
    myerr(sys.exc_info())
    raise
# end of python header, now couple blank lines


