AC_PREREQ([2.67])
AC_INIT([Octave-Forge symbolic package], [2.1.0+])

AC_CHECK_PROG(HAVE_PYTHON, python, [yes], [no])
if test $HAVE_PYTHON = no; then
  AC_MSG_ERROR(failed to find Python)
fi
AX_PYTHON_MODULE(sympy, fatal)
