import sys
sys.ps1 = ""; sys.ps2 = ""
import sympy
#import sympy.abc
import sympy as sp
# FIXME: how to reactivate from srepr w/o this?
from sympy import *
#import dill as pickle
from copy import copy as copy_copy
from binascii import hexlify as binascii_hexlify
from struct import pack as struct_pack, unpack as struct_unpack
import xml.etree.ElementTree as ET

def dbout(l):
    sys.stderr.write("pydebug: " + str(l) + "\n")

# used to pass doubles back-and-forth
def d2hex(x):
    return binascii_hexlify(struct_pack(">d", x))

def hex2d(s):
    bins = ''.join(chr(int(s[x:x+2], 16)) for x in range(0, len(s), 2))
    return struct_unpack('>d', bins)[0]

# Used by evalpy()
def dictdiff(a, b):
    """ keys from a that are not in b """
    n = dict()
    for k in a:
        print str(k)
        if not k in b:
            n[k] = a[k]
    return n


import sympy.printing

class _ReprPrinter_w_asm(sympy.printing.repr.ReprPrinter):
    def _print_Symbol(self, expr):
        asm = expr.assumptions0
        # Not strictly necessary but here are some common cases so we
        # can abbreviate them.  Even better would be some
        # "minimal_assumptions" code, but I didn't see such a thing.
        asm_default = {'commutative':True}
        asm_real = {'commutative':True, 'complex':True, 'hermitian':True, 'imaginary':False, 'real':True}
        asm_pos = {'commutative':True, 'complex':True, 'hermitian':True, 'imaginary':False, 'negative':False, 'nonnegative':True, 'nonpositive':False, 'nonzero':True, 'positive':True, 'real':True, 'zero':False}
        #
        if asm == asm_default:
            xtra = ""
        elif asm == asm_real:
            xtra = ", real=True"
        elif asm == asm_pos:
            xtra = ", positive=True"
        else:
            xtra = ""
            for (key,val) in asm.iteritems():
                xtra = xtra + ", %s=%s" % (key,val)
        return "%s(%s%s)" %  (expr.__class__.__name__, self._print(expr.name), xtra)



def my_srepr(expr, **settings):
    """return expr in repr form w/ assumptions listed"""
    return _ReprPrinter_w_asm(settings).doprint(expr)


def objectfilter(x):
    """Perform final fixes before passing objects back to Octave"""
    #FIXME: replace immutable matrices here?
    if isinstance(x, sp.Matrix) and x.shape == (1,1):
        #dbout("Note: replaced 1x1 mat with scalar")
        y = x[0,0]
    else:
        y = x
    return y


# Single quotes must be replaced with two copies, escape not enough
# Please no extra blank lines within functions (breaks interpret from stdin)
# FIXME: unicode probably do not have enough escaping, but cannot string_escape
def octcmd(x):
    x = objectfilter(x)
    if isinstance(x, (sp.Basic,sp.Matrix)):
        # could escape, but does single quotes too
        #_srepr = sp.srepr(x).encode("string_escape").replace("'", "''")
        _srepr = my_srepr(x).replace("'", "''")
        _str = str(x).encode("string_escape").replace("'", "''")
        _pretty_ascii = \
        sp.pretty(x,use_unicode=False).encode("string_escape").replace("'", "''")
        _pretty_unicode = \
        sp.pretty(x,use_unicode=True).encode("utf-8").replace("\n","\\n").replace("'", "''")
        if isinstance(x, (sp.Matrix, sp.ImmutableMatrix)):
            if isinstance(x, sp.ImmutableMatrix):
                dbout("Warning: ImmutableMatrix")
            _d = x.shape
            s = "sym('" +  _srepr  + "'" + \
                ", [" +  str(_d[0]) + ' ' + str(_d[1])  + ']' + \
                ", '" +  _str  + "'" + \
                ", sprintf('" +  _pretty_ascii  + "')" + \
                ")"
        else:
            if not isinstance(x, sp.Expr):
                dbout("Treating unknown sympy as scalar: " + str(type(x)))
            s = "sym('" +  _srepr  + "'" + \
                ", [1 1]" + \
                ", '" +  _str  + "'" + \
                ", sprintf('" +  _pretty_ascii  + "')" + \
                ")"
    elif isinstance(x, bool) and x:
        s = "true"
    elif isinstance(x, bool) and not x:
        s = "false"
    elif isinstance(x, (list,tuple)):
        s = "{"
        for y in x:
            s = s + octcmd(y) + ",  "
        s = s + "}"
    elif isinstance(x, int):
        s = str(x)
    elif isinstance(x, float):
        # We pass IEEE doubles using the exact hex representation
        s = "hex2num('%s')" % d2hex(x)
    elif isinstance(x, str):
        s = "sprintf('" + x.encode("string_escape").replace("'", "''") + "')"
    elif isinstance(x, unicode):
        # not .encode("string_escape")
        s = "sprintf('" + \
          x.encode("utf-8").replace("\n","\\n").replace("'", "''") + "')"
    elif isinstance(x, dict):
        # Note: the dict cannot be too complex: the keys need to be convertable
        # to strings with str().
        s = "struct("
        for key,val in x.iteritems():
            s = s + "'" + str(key) + "', " + octcmd(val) + ", "
        if len(x) >= 1:
            s = s[:-2]
        s = s + ")"
    else:
        s = "error('python does not know how to export type " + str(type(x)).replace("'", "''") + "')"
    return s



def octoutput_drv(x):
    xroot = ET.Element('output_block')
    octoutput(x, xroot)
    # simple, but no newlines and escapes unicode
    #print ET.tostring(xroot)
    #print "\n"
    # Clashes with some expat lib in Matlab, Issue #63
    import xml.dom.minidom as minidom
    DOM = minidom.parseString(ET.tostring(xroot))
    print DOM.toprettyxml(indent="", newl="\n", encoding="utf-8")


# Please no extra blank lines within functions (breaks interpret from stdin)
# FIXME: unicode probably do not have enough escaping, but cannot string_escape
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
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_BOOL)
        f = ET.SubElement(a, 'f')
        f.text = str(x)
    elif isinstance(x, (sp.Basic,sp.Matrix)):
        if isinstance(x, (sp.Matrix, sp.ImmutableMatrix)):
            if isinstance(x, sp.ImmutableMatrix):
                dbout("Warning: ImmutableMatrix")
            _d = x.shape
        elif isinstance(x, sp.Expr):
            _d = (1,1)
        elif x in (S.true, S.false):
            _d = (1,1)
        else:
            dbout("Treating unknown sympy as scalar: " + str(type(x)))
            _d = (1,1)
        pretty_ascii = sp.pretty(x,use_unicode=False)
        # FIXME: in future, let's just pass both back
        pretty_unicode = sp.pretty(x,use_unicode=True)
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_SYM)
        f = ET.SubElement(a, 'f')
        f.text = my_srepr(x)
        f = ET.SubElement(a, 'f')
        f.text = str(_d[0])
        f = ET.SubElement(a, 'f')
        f.text = str(_d[1])
        f = ET.SubElement(a, 'f')
        f.text = str(x)
        f = ET.SubElement(a, 'f')
        f.text = pretty_ascii
    elif isinstance(x, (list,tuple)):
        c = ET.SubElement(et, 'list')
        for y in x:
            octoutput(y, c)
    elif isinstance(x, int):
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_INT)
        f = ET.SubElement(a, 'f')
        f.text = str(x)
    elif isinstance(x, float):
        # We pass IEEE doubles using the exact hex representation
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_DOUBLE)
        f = ET.SubElement(a, 'f')
        f.text = d2hex(x)
    elif isinstance(x, str):
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_STR)
        f = ET.SubElement(a, 'f')
        f.text = x
    elif isinstance(x, unicode):
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_USTR)
        f = ET.SubElement(a, 'f')
        # newlines are ok with new regexp parser
        #f.text = x.replace("\n","\\n")
        f.text = x
    elif isinstance(x, dict):
        # Note: the dict cannot be too complex, keys must convert to
        # strings for example.  Values can be dicts, lists.
        a = ET.SubElement(et, 'item')
        f = ET.SubElement(a, 'f')
        f.text = str(OCTCODE_DICT)
        # Convert keys to strings
        keystr = [str(y) for y in x.keys()]
        c = ET.SubElement(a, 'list')
        octoutput(keystr, c)
        c = ET.SubElement(a, 'list')
        octoutput(x.values(), c)
    else:
        dbout("error exporting variable:")
        dbout("x: " + str(x))
        dbout("type: " + str(type(x)))
        octoutput("python does not know how to export type " + str(type(x)), et)
