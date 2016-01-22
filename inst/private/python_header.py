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
    from sympy import __version__ as spver
    # need this to reactivate from srepr
    from sympy import *
    import sympy.printing
    from sympy.logic.boolalg import Boolean, BooleanFunction
    from sympy.core.relational import Relational
    # temporary? for piecewise support
    from sympy.functions.elementary.piecewise import ExprCondPair
    from sympy.integrals.risch import NonElementaryIntegral
    from sympy.matrices.expressions.matexpr import MatrixElement
    import copy
    import binascii
    import struct
    import xml.etree.ElementTree as ET
    from distutils.version import LooseVersion
except:
    myerr(sys.exc_info())
    raise


try:
    def dbout(l):
        sys.stderr.write("pydebug: " + str(l) + "\n")
    def d2hex(x):
        # used to pass doubles back-and-forth (.decode for py3)
        return binascii.hexlify(struct.pack(">d", x)).decode()
    def hex2d(s):
        if sys.version_info >= (3, 0):
            bins = bytes([int(s[x:x+2], 16) for x in range(0, len(s), 2)])
        else:
            bins = "".join(chr(int(s[x:x+2], 16)) for x in range(0, len(s), 2))
        return struct.unpack(">d", bins)[0]
    def dictdiff(a, b):
        """ keys from a that are not in b, used by evalpy() """
        n = dict()
        for k in a:
            if not k in b:
                n[k] = a[k]
        return n
    def Version(v):
        # short but not quite right: https://github.com/cbm755/octsympy/pull/320
        return LooseVersion(v.replace('.dev', ''))
except:
    myerr(sys.exc_info())
    raise


# FIXME: Remove all this when we deprecate 0.7.6.x support.
if Version(spver) >= Version("0.7.7.dev"):
    my_srepr = sympy.srepr
else:
    def _monkey_patch_matpow_doit(self, **kwargs):
        deep = kwargs.get('deep', True)
        if deep:
            args = [arg.doit(**kwargs) for arg in self.args]
        else:
            args = self.args
        base = args[0]
        exp = args[1]
        if isinstance(base, MatrixBase) and exp.is_number:
            if exp is S.One:
                return base
            return base**exp
        if exp.is_zero and base.is_square:
            return Identity(base.shape[0])
        elif exp is S.One:
            return base
        return MatPow(base, exp)
    sympy.MatPow.doit = _monkey_patch_matpow_doit
    sympy.MatAdd.doit_orig = sympy.MatAdd.doit
    def _monkey_patch_matadd_doit(self, **kwargs):
        deep = kwargs.get('deep', True)
        if deep:
            args = [arg.doit(**kwargs) for arg in self.args]
        else:
            args = self.args
        return MatAdd(*args).doit_orig(**kwargs)
    sympy.MatAdd.doit = _monkey_patch_matadd_doit
    try:
        class _ReprPrinter_w_asm(sympy.printing.repr.ReprPrinter):
            def _print_Symbol(self, expr):
                asm = expr.assumptions0
                # SymPy < 0.7.7: srepr does not list assumptions.
                # Abbreviate some common cases.
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
                    for (key, val) in asm.items():
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
        #elif isinstance(x, sp.MatrixExpr):
        #    return x.doit()
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
        if sys.version_info >= (3, 0):
            print(DOM.toprettyxml(indent="", newl="\n"))
        else:
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
        elif isinstance(x, (sp.Basic, sp.MatrixBase)):
            if isinstance(x, (sp.Matrix, sp.ImmutableMatrix)):
                _d = x.shape
            elif isinstance(x, sp.MatrixExpr):
                # nan for symbolic size
                _d = [float('nan') if (isinstance(r, sp.Basic) and not r.is_Integer) else r for r in x.shape]
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
        elif isinstance(x, str) or (sys.version_info < (3, 0) and isinstance(x, unicode)):
            a = ET.SubElement(et, "item")
            f = ET.SubElement(a, "f")
            f.text = str(OCTCODE_STR)
            f = ET.SubElement(a, "f")
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
            # FIXME: bit of a kludge, use iterable instead of list, tuple above?
            if sys.version_info >= (3, 0):
                octoutput(list(x.values()), c)
            else:
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


