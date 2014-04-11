How to Install
==============

More to follow, but for now:

1. Run generate_functions.py.  This generates many of the .m files.
   (this will be done before making releases if we ever get that far).

1. Install "dill" [https://github.com/uqfoundation/dill].  For me
    "pip install --user --pre dill" worked.  This is needed for symfuns.

1. Run Octave in the root directory (the one below @sym, @symfun etc).

1. Type "syms x"

1. (optional)  Put the root directory in your Octave path.

1. (optional)  Call run_unit_tests.

