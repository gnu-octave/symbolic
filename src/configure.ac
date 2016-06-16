AC_PREREQ([2.67])
AC_INIT([Octave-Forge symbolic package], [2.5.0-dev])

## Window users seem to often have their path misconfigured (issue #236)
## so we check if we really are running GNU sort
AC_PATH_PROG(SORT, sort)
AC_MSG_CHECKING(for GNU coreutils)
$SORT --version 2>/dev/null | grep -q GNU
if test $? -ne 0;
then
  AC_MSG_RESULT(no)
  AC_MSG_ERROR([The sort program is not GNU sort.  Please configure your PATH])
else
  AC_MSG_RESULT(yes)
fi

AC_CHECK_PROG(PYTHON, python, [python], [])
if test -z "$PYTHON"; then
  AC_MSG_WARN(Failed to find Python: many features will not work)
fi

AC_MSG_CHECKING(for SymPy version)
min_sympy_version='1.0'
version=`$PYTHON -c "import sympy; print(sympy.__version__)" 2>/dev/null`
if test $? -eq 0; then
  AC_MSG_RESULT($version)
else
  AC_MSG_RESULT(no)
  AC_MSG_WARN(Failed to import SymPy: many features will not work)
fi
AX_COMPARE_VERSION($version, ge, $min_sympy_version, [], [
  AC_MSG_WARN(SymPy version $min_sympy_version or later is recommended)
])
