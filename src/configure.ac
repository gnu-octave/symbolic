AC_PREREQ([2.67])
AC_INIT([Octave-Forge symbolic package], [2.2.2-dev])

AC_PATH_PROG(PYTHON, python)
if test -z $PYTHON; then
  AC_MSG_ERROR(Failed to find Python)
fi

AX_PYTHON_MODULE(sympy, fatal)

AC_MSG_CHECKING(checking for SymPy version)
min_sympy_version='0.7.5'
version=`$PYTHON -c "import sympy; print(sympy.__version__)" 2>/dev/null`
if test $? -eq 0; then
  AC_MSG_RESULT($version)
else
  AC_MSG_RESULT(no)
  AC_MSG_ERROR(Failed to import SymPy)
fi
AX_COMPARE_VERSION($version, ge, $min_sympy_version, [], [
  AC_MSG_ERROR(SymPy version $min_sympy_version or later is required)
])
