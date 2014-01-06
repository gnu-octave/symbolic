AC_PREREQ([2.2])
AC_INIT([Octave-Forge symbolic package], [1.1.0+])

AC_PROG_CXX

dnl Checking for ginac library
PKG_CHECK_MODULES(GINAC, ginac, , [AC_MSG_ERROR([GINAC not found])])
  
dnl Check for gmp library
dnl AC_CHECK_LIB(gmp, __gmpz_init, , [AC_MSG_ERROR([GNU MP not found])])
