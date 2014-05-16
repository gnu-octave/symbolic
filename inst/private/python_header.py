import sys
sys.ps1 = ""; sys.ps2 = ""
import sympy
#import sympy.abc
import sympy as sp
# FIXME: how to reactivate from srepr w/o this?
from sympy import *
#import dill as pickle
import copy


def dbout(l):
    sys.stderr.write("pydebug: " + str(l) + "\n")


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
        # FIXME: see Bug #11
        s = "%.20g" % x
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

